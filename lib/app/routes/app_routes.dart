enum AppRoutes {
  auth('/auth'),
  feed('/feed'),
  timeline('/timeline'),
  createMedia('/create-media'),
  reels('/reels'),
  user('/user'),
  userProfile('/user-profile', path: '/users/:user_id'),
  editProfile('/editProfile'),
  chat('/chat', path: '/chats/:chat_id'),
  createStories('/create-stories'),
  userStatistics('/user-statistics'),
  editProfileInfo('/edit-profile-info', path: 'edit/:label'),
  publisPost('/publis-post'),
  search('/search'),
  createPost('/create-post'),
  userPosts('/user-posts'),
  postEdit('/post-edit', path: '/posts/:post_id/edit'),
  post('/post', path: '/posts/:id'),
  stories('/stories', path: '/posts/:user_id');

  const AppRoutes(this.route, {this.path});

  final String route;
  final String? path;

  String get name => route.replaceAll('/', '');
}
