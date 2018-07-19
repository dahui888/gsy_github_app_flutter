import 'package:gsy_github_app_flutter/common/dao/DaoResult.dart';
import 'package:gsy_github_app_flutter/common/net/Address.dart';
import 'package:gsy_github_app_flutter/common/net/Api.dart';
import 'package:gsy_github_app_flutter/common/net/trending/GithubTrending.dart';
import 'package:gsy_github_app_flutter/widget/EventItem.dart';
import 'package:gsy_github_app_flutter/widget/ReposHeaderItem.dart';
import 'package:gsy_github_app_flutter/widget/ReposItem.dart';

/**
 * Created by guoshuyu
 * Date: 2018-07-16
 */

class ReposDao {
  /**
   * 趋势数据
   * @param page 分页，趋势数据其实没有分页
   * @param since 数据时长， 本日，本周，本月
   * @param languageType 语言
   */
  static getTrendDao({since = 'daily', languageType, page = 0}) async {
    String localLanguage = (languageType != null) ? languageType : "*";
    String url = Address.trending(since, localLanguage);
    var res = await new GitHubTrending().fetchTrending(url);
    if (res != null && res.result && res.data.length > 0) {
      List<ReposViewModel> list = new List();
      var data = res.data;
      if (data == null || data.length == 0) {
        return new DataResult(null, false);
      }
      for (int i = 0; i < data.length; i++) {
        TrendingRepoModel model = data[i];
        ReposViewModel reposViewModel = new ReposViewModel();
        reposViewModel.ownerName = model.name;
        reposViewModel.ownerPic = model.contributors[0];
        reposViewModel.repositoryName = model.reposName;
        reposViewModel.repositoryStar = model.starCount;
        reposViewModel.repositoryFork = model.forkCount;
        reposViewModel.repositoryWatch = model.meta;
        reposViewModel.repositoryType = model.language;
        reposViewModel.repositoryDes = model.description;
        list.add(reposViewModel);
      }
      return new DataResult(list, true);
    } else {
      return new DataResult(null, false);
    }
  }

  /**
   * 仓库的详情数据
   */
  static getRepositoryDetailDao(userName, reposName) async {
    String url = Address.getReposDetail(userName, reposName);
    var res = await HttpManager.netFetch(url, null, {"Accept": 'application/vnd.github.mercy-preview+json'}, null);
    if (res != null && res.result && res.data.length > 0) {
      List<ReposHeaderViewModel> list = new List();
      var data = res.data;
      if (data == null || data.length == 0) {
        return new DataResult(null, false);
      }
      return new DataResult(ReposHeaderViewModel.fromHttpMap(reposName, userName, data), true);
    } else {
      return new DataResult(null, false);
    }
  }

  /**
   * 仓库活动事件
   */
  static getRepositoryEventDao(userName, reposName, {page = 0}) async {
    String url = Address.getReposEvent(userName, reposName) + Address.getPageParams("?", page);
    var res = await HttpManager.netFetch(url, null, null, null);
    if (res != null && res.result) {
      List<EventViewModel> list = new List();
      var data = res.data;
      if (data == null || data.length == 0) {
        return new DataResult(null, false);
      }
      for (int i = 0; i < data.length; i++) {
        list.add(EventViewModel.fromEventMap(data[i]));
      }
      return new DataResult(list, true);
    } else {
      return new DataResult(null, false);
    }
  }

  /**
   * 获取用户对当前仓库的star、watcher状态
   */
  static getRepositoryStatusDao(userName, reposName) async {
    String urls = Address.resolveStarRepos(userName, reposName);
    String urlw = Address.resolveWatcherRepos(userName, reposName);
    var resS = await HttpManager.netFetch(urls, null, null, null, noTip: true);
    var resW = await HttpManager.netFetch(urlw, null, null, null, noTip: true);
    var data = {"star": resS.result, "watch": resW.result};
    return new DataResult(data, true);
  }

}