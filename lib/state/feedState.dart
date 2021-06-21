import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:one_person_twitter/helper/enum.dart';
import 'package:one_person_twitter/model/feedModel.dart';
import 'package:one_person_twitter/helper/utility.dart';
import 'package:one_person_twitter/model/user.dart';
import 'package:one_person_twitter/state/appState.dart';
import 'package:path/path.dart' as Path;

class FeedState extends AppState {
  bool isBusy = false;
  Map<String, List<FeedModel>> tweetReplyMap = {};
  FeedModel _tweetToReplyModel;
  FeedModel get tweetToReplyModel => _tweetToReplyModel;
  set setTweetToReply(FeedModel model) {
    _tweetToReplyModel = model;
  }

  List<FeedModel> _commentlist;

  List<FeedModel> _feedlist;
  dabase.Query _feedQuery;
  List<FeedModel> _tweetDetailModelList;
  List<String> _userfollowingList;
  List<String> get followingList => _userfollowingList;

  List<FeedModel> get tweetDetailModel => _tweetDetailModelList;

  List<FeedModel> get feedlist {
    if (_feedlist == null) {
      return null;
    } else {
      return List.from(_feedlist.reversed);
    }
  }

  List<FeedModel> getTweetList(UserModel userModel) {
    if (userModel == null) {
      isBusy = false;
      return null;
    }

    List<FeedModel> list;

    if (!isBusy && feedlist != null && feedlist.isNotEmpty) {
      list = feedlist.where((x) {
        /// If Tweet is a comment then no need to add it in tweet list
        if (x.parentkey != null &&
            x.childRetwetkey == null &&
            x.user.userId != userModel.userId) {
          return false;
        }

        /// Only include Tweets of logged-in user's and his following user's
        if (x.user.userId == userModel.userId ||
            (userModel?.followingList != null &&
                userModel.followingList.contains(x.user.userId))) {
          return true;
        } else {
          return false;
        }
      }).toList();
      if (list.isEmpty) {
        list = null;
      }
    }
    isBusy = false;
    return list;
  }

  set setFeedModel(FeedModel model) {
    if (_tweetDetailModelList == null) {
      _tweetDetailModelList = [];
    }

    /// [Skip if any duplicate tweet already present]
    if (_tweetDetailModelList.length >= 0) {
      _tweetDetailModelList.add(model);
      cprint(
          "Detail Tweet added. Total Tweet: ${_tweetDetailModelList.length}");
      notifyListeners();
    }
  }

  void removeLastTweetDetail(String tweetKey) {
    if (_tweetDetailModelList != null && _tweetDetailModelList.length > 0) {
      // var index = _tweetDetailModelList.in
      FeedModel removeTweet =
          _tweetDetailModelList.lastWhere((x) => x.key == tweetKey);
      _tweetDetailModelList.remove(removeTweet);
      tweetReplyMap.removeWhere((key, value) => key == tweetKey);
      cprint(
          "Last index Tweet removed from list. Remaining Tweet: ${_tweetDetailModelList.length}");
      notifyListeners();
    }
  }

  void clearAllDetailAndReplyTweetStack() {
    if (_tweetDetailModelList != null) {
      _tweetDetailModelList.clear();
    }
    if (tweetReplyMap != null) {
      tweetReplyMap.clear();
    }
    cprint('Empty tweets from stack');
  }

  Future<bool> databaseInit() {
    try {
      if (_feedQuery == null) {
        _feedQuery = kDatabase.child("tweet");
        _feedQuery.onChildAdded.listen(_onTweetAdded);
        _feedQuery.onValue.listen(_onTweetChanged);
        _feedQuery.onChildRemoved.listen(_onTweetRemoved);
      }

      return Future.value(true);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return Future.value(false);
    }
  }

  void getDataFromDatabase() {
    try {
      isBusy = true;
      _feedlist = null;
      notifyListeners();
      kDatabase.child('tweet').once().then((DataSnapshot snapshot) {
        _feedlist = <FeedModel>[];
        if (snapshot.value != null) {
          var map = snapshot.value;
          if (map != null) {
            map.forEach((key, value) {
              var model = FeedModel.fromJson(value);
              model.key = key;
              if (model.isValidTweet) {
                _feedlist.add(model);
              }
            });

            _feedlist.sort((x, y) => DateTime.parse(x.createdAt)
                .compareTo(DateTime.parse(y.createdAt)));
          }
        } else {
          _feedlist = null;
        }
        isBusy = false;
        notifyListeners();
      });
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  void getpostDetailFromDatabase(String postID, {FeedModel model}) async {
    try {
      FeedModel _tweetDetail;
      if (model != null) {
        // set tweet data from tweet list data.
        // No need to fetch tweet from firebase db if data already present in tweet list
        _tweetDetail = model;
        setFeedModel = _tweetDetail;
        postID = model.key;
      } else {
        // Fetch tweet data from firebase
        kDatabase
            .child('tweet')
            .child(postID)
            .once()
            .then((DataSnapshot snapshot) {
          if (snapshot.value != null) {
            var map = snapshot.value;
            _tweetDetail = FeedModel.fromJson(map);
            _tweetDetail.key = snapshot.key;
            setFeedModel = _tweetDetail;
          }
        });
      }

      if (_tweetDetail != null) {
        // Fetch comment tweets
        _commentlist = <FeedModel>[];
        // Check if parent tweet has reply tweets or not
        if (_tweetDetail.replyTweetKeyList != null &&
            _tweetDetail.replyTweetKeyList.length > 0) {
          _tweetDetail.replyTweetKeyList.forEach((x) {
            if (x == null) {
              return;
            }
            kDatabase
                .child('tweet')
                .child(x)
                .once()
                .then((DataSnapshot snapshot) {
              if (snapshot.value != null) {
                var commentmodel = FeedModel.fromJson(snapshot.value);
                var key = snapshot.key;
                commentmodel.key = key;

                if (!_commentlist.any((x) => x.key == key)) {
                  _commentlist.add(commentmodel);
                }
              } else {}
              if (x == _tweetDetail.replyTweetKeyList.last) {
                _commentlist.sort((x, y) => DateTime.parse(y.createdAt)
                    .compareTo(DateTime.parse(x.createdAt)));
                tweetReplyMap.putIfAbsent(postID, () => _commentlist);
                notifyListeners();
              }
            });
          });
        } else {
          tweetReplyMap.putIfAbsent(postID, () => _commentlist);
          notifyListeners();
        }
      }
    } catch (error) {
      cprint(error, errorIn: 'getpostDetailFromDatabase');
    }
  }

  Future<FeedModel> fetchTweet(String postID) async {
    FeedModel _tweetDetail;
    if (feedlist.any((x) => x.key == postID)) {
      _tweetDetail = feedlist.firstWhere((x) => x.key == postID);
    } else {
      cprint("Fetched from DB: " + postID);
      var model = await kDatabase.child('tweet').child(postID).once().then(
        (DataSnapshot snapshot) {
          if (snapshot.value != null) {
            var map = snapshot.value;
            _tweetDetail = FeedModel.fromJson(map);
            _tweetDetail.key = snapshot.key;
            print(_tweetDetail.description);
          }
        },
      );
      if (model != null) {
        _tweetDetail = model;
      } else {
        cprint("Fetched null value from  DB");
      }
    }
    return _tweetDetail;
  }

  createTweet(FeedModel model) {
    isBusy = true;
    notifyListeners();
    try {
      kDatabase.child('tweet').push().set(model.toJson());
    } catch (error) {
      cprint(error, errorIn: 'createTweet');
    }
    isBusy = false;
    notifyListeners();
  }

  deleteTweet(String tweetId, TweetType type, {String parentkey}) {
    try {
      kDatabase.child('tweet').child(tweetId).remove().then((_) {
        if (type == TweetType.Detail &&
            _tweetDetailModelList != null &&
            _tweetDetailModelList.length > 0) {
          _tweetDetailModelList.remove(_tweetDetailModelList);
          if (_tweetDetailModelList.length == 0) {
            _tweetDetailModelList = null;
          }

          cprint('Tweet deleted from nested tweet detail page tweet');
        }
      });
    } catch (error) {
      cprint(error, errorIn: 'deleteTweet');
    }
  }

  Future<String> uploadFile(File file) async {
    try {
      isBusy = true;
      notifyListeners();
      var storageReference = FirebaseStorage.instance
          .ref()
          .child("tweetImage")
          .child(Path.basename(DateTime.now().toIso8601String() + file.path));
      await storageReference.putFile(file);

      var url = await storageReference.getDownloadURL();
      if (url != null) {
        return url;
      }
      return null;
    } catch (error) {
      cprint(error, errorIn: 'uploadFile');
      return null;
    }
  }

  Future<void> deleteFile(String url, String baseUrl) async {
    try {
      var filePath = url.split(".com/o/")[1];
      filePath = filePath.replaceAll(new RegExp(r'%2F'), '/');
      filePath = filePath.replaceAll(new RegExp(r'(\?alt).*'), '');
      cprint('[Path]' + filePath);
      var storageReference = FirebaseStorage.instance.ref();
      await storageReference.child(filePath).delete().catchError((val) {
        cprint('[Error]' + val);
      }).then((_) {
        cprint('[Sucess] Image deleted');
      });
    } catch (error) {
      cprint(error, errorIn: 'deleteFile');
    }
  }

  updateTweet(FeedModel model) async {
    await kDatabase.child('tweet').child(model.key).set(model.toJson());
  }

  _onTweetChanged(Event event) {
    var model = FeedModel.fromJson(event.snapshot.value);
    model.key = event.snapshot.key;
    if (_feedlist.any((x) => x.key == model.key)) {
      var oldEntry = _feedlist.lastWhere((entry) {
        return entry.key == event.snapshot.key;
      });
      _feedlist[_feedlist.indexOf(oldEntry)] = model;
    }

    if (_tweetDetailModelList != null && _tweetDetailModelList.length > 0) {
      if (_tweetDetailModelList.any((x) => x.key == model.key)) {
        var oldEntry = _tweetDetailModelList.lastWhere((entry) {
          return entry.key == event.snapshot.key;
        });
        _tweetDetailModelList[_tweetDetailModelList.indexOf(oldEntry)] = model;
      }
      if (tweetReplyMap != null && tweetReplyMap.length > 0) {
        if (true) {
          var list = tweetReplyMap[model.parentkey];
          //  var list = tweetReplyMap.values.firstWhere((x) => x.any((y) => y.key == model.key));
          if (list != null && list.length > 0) {
            var index =
                list.indexOf(list.firstWhere((x) => x.key == model.key));
            list[index] = model;
          } else {
            list = [];
            list.add(model);
          }
        }
      }
    }
    if (event.snapshot != null) {
      cprint('Tweet updated');
      isBusy = false;
      notifyListeners();
    }
  }

  _onTweetAdded(Event event) {
    FeedModel tweet = FeedModel.fromJson(event.snapshot.value);
    tweet.key = event.snapshot.key;
    tweet.key = event.snapshot.key;
    if (_feedlist == null) {
      _feedlist = <FeedModel>[];
    }
    if ((_feedlist.length == 0 || _feedlist.any((x) => x.key != tweet.key)) &&
        tweet.isValidTweet) {
      _feedlist.add(tweet);
      cprint('Tweet Added');
    }
    isBusy = false;
    notifyListeners();
  }

  _onTweetRemoved(Event event) async {
    FeedModel tweet = FeedModel.fromJson(event.snapshot.value);
    tweet.key = event.snapshot.key;
    var tweetId = tweet.key;
    var parentkey = tweet.parentkey;

    try {
      FeedModel deletedTweet;
      if (_feedlist.any((x) => x.key == tweetId)) {
        deletedTweet = _feedlist.firstWhere((x) => x.key == tweetId);
        _feedlist.remove(deletedTweet);

        if (deletedTweet.parentkey != null &&
            _feedlist.isNotEmpty &&
            _feedlist.any((x) => x.key == deletedTweet.parentkey)) {
          // Decrease parent Tweet comment count and update
          var parentModel =
              _feedlist.firstWhere((x) => x.key == deletedTweet.parentkey);
          parentModel.replyTweetKeyList.remove(deletedTweet.key);
          parentModel.commentCount = parentModel.replyTweetKeyList.length;
          updateTweet(parentModel);
        }
        if (_feedlist.length == 0) {
          _feedlist = null;
        }
        cprint('Tweet deleted from home page tweet list');
      }

      /// [Delete tweet] if it is in nested tweet detail comment section page
      if (parentkey != null &&
          parentkey.isNotEmpty &&
          tweetReplyMap != null &&
          tweetReplyMap.length > 0 &&
          tweetReplyMap.keys.any((x) => x == parentkey)) {
        // (type == TweetType.Reply || tweetReplyMap.length > 1) &&
        deletedTweet =
            tweetReplyMap[parentkey].firstWhere((x) => x.key == tweetId);
        tweetReplyMap[parentkey].remove(deletedTweet);
        if (tweetReplyMap[parentkey].length == 0) {
          tweetReplyMap[parentkey] = null;
        }

        if (_tweetDetailModelList != null &&
            _tweetDetailModelList.isNotEmpty &&
            _tweetDetailModelList.any((x) => x.key == parentkey)) {
          var parentModel =
              _tweetDetailModelList.firstWhere((x) => x.key == parentkey);
          parentModel.replyTweetKeyList.remove(deletedTweet.key);
          parentModel.commentCount = parentModel.replyTweetKeyList.length;
          cprint('Parent tweet comment count updated on child tweet removal');
          updateTweet(parentModel);
        }

        cprint('Tweet deleted from nested tweet detail comment section');
      }

      /// Delete tweet image from firebase storage if exist.
      if (deletedTweet.imagePath != null && deletedTweet.imagePath.length > 0) {
        deleteFile(deletedTweet.imagePath, 'tweetImage');
      }

      /// If a retweet is deleted then retweetCount of original tweet should be decrease by 1.
      if (deletedTweet.childRetwetkey != null) {
        await fetchTweet(deletedTweet.childRetwetkey).then((retweetModel) {
          if (retweetModel == null) {
            return;
          }
          if (retweetModel.retweetCount > 0) {
            retweetModel.retweetCount -= 1;
          }
          updateTweet(retweetModel);
        });
      }

      /// Delete notification related to deleted Tweet.
      if (deletedTweet.likeCount > 0) {
        kDatabase
            .child('notification')
            .child(tweet.userId)
            .child(tweet.key)
            .remove();
      }
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: '_onTweetRemoved');
    }
  }
}
