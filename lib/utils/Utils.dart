class Utils{
  static String createUserId(String email){
    String userId = email.split('@')[0] + 
      email.split('@')[1].split('.')[0];
    return userId;
  }
  static String randomMeetingLinkGenerator(){
    String meetingId = DateTime.now().millisecondsSinceEpoch.toString();
    meetingId += 'chatapp';
    return meetingId;
  }

}