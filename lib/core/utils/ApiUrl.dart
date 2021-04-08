class ApiUrl {
  //
  static const BASE_URL = "https://api.stoppoint.com/api";
//static const BASE_URL = "http://192.168.0.28:3000/api";
 // static const BASE_URL = "http://192.168.0.116:3000/api";

  static const CLOUDINARY_KEY = "448182769163657";
  static const CLOUDINARY_SECRET = "fj1WSnsts5rka3q63JcoQKNW_zo";
  static const CLODINARY_CLOUD_NAME = "stoppoint";
  static const LOGIN = '/auth/login';
  static const REGISTER = '/user';
  static const UPDATE_USER = '/user/';
  static const TEST_URL = 'https://jsonplaceholder.typicode.com/posts';
  static const USER_PROFILE = '/user/getProfile/';
  static const BLOCK_USER ="/user/blockUser";
  static const UNBLOCK_USER ="/user/unblockUser";
  static const BLOCK_USER_MESSAGE ="/user/blockUserMessage";
  static const UNBLOCK_USER_MESSAGE ="/user/unblockUserMessage";
  static const USER_ADD_INTERESTS = '/interest/addInterests/';
  static const GET_INTERESTS = '/interest';
  static const FOLLOW_INTEREST = '/interest/follow';
  static const INTERESTS_WITH_VIDEOS = '/interest/InterestsWithVideos';
  static const UNFOLLOW_INTEREST = '/interest/unfollow';
  static const GET_SUGGESTED_AND_RECENT = '/user/getSuggestAndRecentList/';
  static const GET_USER_FOR_FOLLOW = '/user/getSuggestionForFollow/';
  static const SEND_QUESTION = '/question/askQuestion';
  static const SEND_VIDEO = '/question/askQuestionVideo';
  static const ANSWER_QUESTION = '/question/answerQuestion';
  static const SAVE_FOR_LATER = '/question/saveForLater';
  static const ARCHIVE_QUESTION = '/question/archive';
  static const SHARE_QUESTION = '/question/share';
  static const QUESTION ='/question';
  static const UPDATE_QUESTION ='/question/';
  static const QUESTION_INTEREST ='/question/interest/';
  static const GET_RELATED_QUESTIONS ='/question/getRelatedQuestions';
  static const GET_QUESTION_BY_ID = '/question/getQuestionById';
  static const UPVOTE_ANSWER = '/answer/upVote';
  static const DOWNVOTE_ANSWER = '/answer/downVote';
  static const LIKE_ANSWER ='/answer/like';
  static const DISLIKE_ANSWER = '/answer/dislike';
  static const ADD_VIEW_COUNT = '/answer/addView';
  static const GET_USERS_BY_QUERY = '/user/getUsersByQuery';
  static const GET_FEED = '/feed/get';
  static const FOLLOW_USER = '/user/follow';
  static const UNFOLLOW_USER = '/user/unfollow';
  static const GET_CHATS = '/chat/getLastByKind';
  static const GET_CHATS_BY_USER = '/chat/getByKindFromTo';
  static const DELETE_CHATS_BY_USER = '/chat/deleteByKindFromTo';

  static const SEND_REPORT = '/report/report';

  static const GET_PREVIEW_EXPLORE = '/question/explorePreview/';
  static const GET_QUESTION_BY_TEXT = '/question/getQuestionByName/';
  static const GET_QUESTIONS_BY_INTEREST = '/question/basedOnInterest';
  static const ANSWER = '/question/answer';
  static const GET_EXPLORE_ITEMS = "/explore/getInformation";
  static const GET_USER_NOTIFICATIONS = "/notification/getUserNotifications/";

  //XMPP Server configuration
  static const XMPP_SERVER_ADDRESS = "3.129.18.242";
  static const XMPP_SERVER_PORT = 5222;
  static const XMPP_SERVER_DOMAIN = "videoapp";

  static const ACCEPT_FOLLOW = '/user/acceptFollow';
  static const DECLINE_FOLLOW = '/user/declineFollow';
  static const SEND_COMMENT = '/answer/comment';
  static const GET_COMMENTS = '/answer/comment/';
  static const DELETE_COMMENTS = '/answer/deleteComment/';
  static const UPDATE_COMMENTS = '/answer/updatecomment';
  static const COMMENT_VOTE = '/question/comment/vote';
}
