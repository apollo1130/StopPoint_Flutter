import 'package:basic_utils/basic_utils.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:video_app/questions/models/QuestionData.dart';

class DynamicLinkProvider {
  static Future<Uri> generateDynamicLink(
    String type,
    Map<String, dynamic> queryParameters,QuestionData questionData
  ) async {
    Uri outgoingUri = Uri(
      host: "share.stoppoint.com",
      path: type,
      queryParameters: queryParameters,
      scheme: "https",
    );
    String url=questionData.answers.isNotEmpty?questionData.answers.first.video.replaceAll(".mp4", ".jpg"):"";
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      socialMetaTagParameters: SocialMetaTagParameters(
        imageUrl: Uri.parse(url),
        description: "",
        title: StringUtils.capitalize(
            questionData.text) +
            '?'
      ),
      uriPrefix: 'https://share.stoppoint.com',
      link: outgoingUri,
      androidParameters: AndroidParameters(
        packageName: 'com.video_app',
      ),
      iosParameters: IosParameters(
        bundleId: 'com.sVideoApp',
        //minimumVersion: '1.0.1',
      ),
    );

    final Uri dynamicUrl = await parameters.buildUrl();

    return dynamicUrl;
  }
}
