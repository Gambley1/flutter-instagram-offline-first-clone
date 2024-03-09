-- Set up storage for avatars!
insert into storage.buckets (id, name)
  values ('avatars', 'avatars');

-- Set up access controls for storage.
create policy "Avatar images are publicly accessible." on storage.objects
  for select using (bucket_id = 'avatars');

create policy "Anyone can upload an avatar." on storage.objects
  for insert with check (bucket_id = 'avatars');

create policy "Anyone can update their own avatar." on storage.objects
  for update using (auth.uid() = owner) with check (bucket_id = 'avatars');

create policy "Anyone can delete their own avatar." on storage.objects for delete using (
  bucket_id = 'avatars'
  and auth.uid ()::text = (storage.foldername (name)) [1]
);

-- Set up storage for posts.
insert into storage.buckets (id, name)
  values ('posts', 'posts');

create policy "Only authenticated users can see post media." on storage.objects for
select
  to authenticated using (bucket_id = 'posts');

create policy "Only authenticated users can upload post media." on storage.objects for insert
 to authenticated
   with
      check (
        bucket_id = 'posts'
        );

create policy "Only authenticated can delete posts media." on storage.objects for delete
 to authenticated 
  using (
    bucket_id = 'posts'
  );

create policy "Only authenticated can update posts media." on storage.objects
for update
  to authenticated using (
    bucket_id = 'posts'
  );

-- Set up storage for stories!
insert into storage.buckets (id, name)
  values ('stories', 'stories');

create policy "Only authenticated user can see stories media." on storage.objects for
select
  to authenticated using (bucket_id = 'stories');

create policy "Only authenticated can upload stories media." on storage.objects for insert
 to authenticated
   with
      check (
        bucket_id = 'stories'
        );

create policy "Only authenticated can delete stories media." on storage.objects for delete
 to authenticated 
  using (
    bucket_id = 'stories'
  );

create policy "Only authenticated can update stories media." on storage.objects
for update
  to authenticated using (
    bucket_id = 'stories'
  );

create table
  public.profiles (
    id uuid not null,
    full_name text not null,
    email text not null,
    username text not null,
    avatar_url text null,
    push_token text null,
    constraint profiles_pkey primary key (id),
    constraint profiles_email_key unique (email),
    constraint profiles_id_fkey foreign key (id) references auth.users (id) on update cascade on delete cascade,
    constraint username_length check (
      (
        (char_length(username) >= 3)
        and (char_length(username) <= 16)
      )
    )
  ) tablespace pg_default;

alter table profiles enable row level security;

create policy "Profiles are viewable by everyone." on profiles
  for select using (true);

create policy "Allow to create profiles for everyone." on profiles
  for insert with check (true);

create policy "Only owner can update the profile." on profiles
  for update with check (auth.uid() = id);

create policy "Only owner can delete the profile." on profiles
  for delete using (auth.uid() = id);

create type media_type as enum('photo', 'video');

-- Create Posts table
create table
  public.posts (
    id uuid not null default gen_random_uuid (),
    user_id uuid not null,
    caption text null,
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone null,
    media text null,
    constraint posts_pkey primary key (id),
    constraint posts_user_id_fkey foreign key (user_id) references profiles (id) on update cascade on delete cascade
  ) tablespace pg_default;

alter table posts enable row level security;

create policy "Allow to see posts for everybody." on public.posts for select using (true);

create policy "Allow upload post only to authenticated user." on public.posts
 for insert to authenticated with check (true);

create policy "Allow update post only to owner." on public.posts for update to authenticated
with
  check (
    auth.uid() = user_id
  );

create policy "Allow delete post only to owner." on public.posts for delete to authenticated
using (
    auth.uid() = user_id
  );

-- Create Videos table
create table
  public.videos (
    id uuid not null,
    owner_id uuid not null,
    url text not null,
    first_frame_url text not null,
    blur_hash text not null,
    constraint videos_pkey primary key (id),
    constraint videos_user_id_fkey foreign key (owner_id) references profiles (id) on update cascade on delete cascade
  ) tablespace pg_default;

alter table videos enable row level security;

create policy "Allow to see videos for everybody" on public.videos for select using (true);

create policy "Allow upload video only to authenticated user." on public.videos
 for insert to authenticated with check (true);

create policy "Only owner can update video." on public.videos for update to authenticated
with
  check (
    auth.uid() = owner_id
  );

create policy "Only owner can delete video." on public.videos for delete to authenticated
using (
    auth.uid() = owner_id
  );

-- Create Images table
create table
  public.images (
    id uuid not null,
    owner_id uuid not null,
    url text not null,
    blur_hash text null,
    constraint images_pkey primary key (id),
    constraint images_owner_id_fkey foreign key (owner_id) references public.profiles (id) on update cascade on delete cascade
  ) tablespace pg_default;

alter table images enable row level security;

create policy "Allow to see images for everybody." on public.images for select using (true);

create policy "Allow upload image only to authenticated user." on public.images
 for insert to authenticated with check (true);

create policy "Allow update image only to owner." on public.images for update to authenticated
with
  check (
    auth.uid() = owner_id
  );

create policy "Allow delete image only to owner." on public.images for delete to authenticated
using (
    auth.uid() = owner_id
  );

-- Create comments table

create table
  public.comments (
    id uuid not null,
    post_id uuid not null,
    user_id uuid not null,
    content text not null,
    created_at timestamp with time zone not null default now(),
    replied_to_comment_id uuid null,
    constraint comments_pkey primary key (id),
    constraint comments_post_id_fkey foreign key (post_id) references posts (id) on update cascade on delete cascade,
    constraint comments_replied_to_comment_id_fkey foreign key (replied_to_comment_id) references comments (id) on update cascade on delete cascade,
    constraint comments_user_id_fkey foreign key (user_id) references profiles (id) on update cascade on delete cascade
  ) tablespace pg_default;

alter table comments enable row level security;

create policy "Everyone can see posts comments." on public.comments for select using (true);

create policy "Only owners can update comment." on public.comments for update with check(
    auth.uid() = user_id
  );

create policy "Only authenticated can upload comments." on public.comments for insert to authenticated with check (true);

create policy "Only owners can delete comment." on public.comments for delete to authenticated
using (
    auth.uid() = user_id
  );

-- Create Likes table
  
create table
  public.likes (
    id uuid not null default gen_random_uuid (),
    post_id uuid null,
    user_id uuid not null,
    comment_id uuid null,
    constraint likes_pkey primary key (id),
    constraint likes_comment_id_key unique (user_id, comment_id),
    constraint likes_post_id_key unique (user_id, post_id),
    constraint likes_comment_id_fkey foreign key (comment_id) references comments (id) on update cascade on delete cascade,
    constraint likes_post_id_fkey foreign key (post_id) references posts (id) on update cascade on delete cascade,
    constraint likes_user_id_fkey foreign key (user_id) references profiles (id) on update cascade on delete cascade,
    constraint like_has_either_comment_or_post check (
      (
        (
          (comment_id is not null)
          and (post_id is null)
        )
        or (
          (comment_id is null)
          and (post_id is not null)
        )
      )
    )
  ) tablespace pg_default;

alter table likes enable row level security;

create policy "Everyone can see posts likes" on public.likes for select using (true);

create policy "Only authenticated can upload likes" on public.likes for insert to authenticated with check (true);

create policy "Only owner can update like" on public.likes for update to authenticated
with
  check (
    auth.uid() = user_id
  );

create policy "Only onwner can delete like" on public.likes for delete to authenticated
using (
    auth.uid() = user_id
  );

create table
  public.subscriptions (
    id uuid not null,
    subscriber_id uuid not null,
    subscribed_to_id uuid not null,
    constraint subscriptions_pkey primary key (id),
    constraint subscriptions_subscribed_to_id_fkey foreign key (subscribed_to_id) references profiles (id) on update cascade on delete cascade,
    constraint subscriptions_subscriber_id_fkey foreign key (subscriber_id) references profiles (id) on update cascade on delete cascade
  ) tablespace pg_default;

alter table subscriptions enable row level security;

create policy "Every user can see other users subscribers count." on public.subscriptions
  for select using (true);

create policy "Only authenticated users can subscribe to other users." on public.subscriptions
 for insert to authenticated with check (true);

create policy "Only authentiaceted users can unsubscribe from other users." on public.subscriptions 
  for delete to authenticated
    using (
      auth.uid() = subscribed_to_id OR auth.uid() = subscriber_id
    );

create type conversation_type as enum('one-on-one', 'group');

create table
  public.conversations (
    id uuid not null default gen_random_uuid (),
    type conversation_type not null,
    name text not null,
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone not null default now(),
    constraint conversations_pkey primary key (id)
  ) tablespace pg_default;

alter table conversations enable row level security;

create policy "Everybody can see conversations they participate in." on public.conversations
  for select using (true);

create policy "Only authenticated users can create conversations with other users." on public.conversations
 for insert to authenticated with check(true);

create policy "Only authentiaceted users can delete conversations they participate in." on public.conversations 
  for delete to authenticated using (true); 

-- Create participants talbe
create table
  public.participants (
    id uuid not null default gen_random_uuid (),
    user_id uuid not null,
    conversation_id uuid not null,
    constraint participants_pkey primary key (id),
    constraint unique_participant unique (user_id, conversation_id),
    constraint participants_conversation_id_fkey foreign key (conversation_id) references conversations (id) on update cascade on delete cascade,
    constraint participants_user_id_fkey foreign key (user_id) references profiles (id) on update cascade on delete cascade
  ) tablespace pg_default;

alter table participants enable row level security;

create type message_type as enum('text', 'image', 'video', 'voice');

create table
  public.messages (
    id uuid not null default gen_random_uuid (),
    conversation_id uuid not null,
    from_id uuid not null,
    type message_type not null,
    message text not null,
    reply_message_id uuid null,
    created_at timestamp with time zone not null default (now() at time zone 'utc'::text),
    updated_at timestamp with time zone not null default (now() at time zone 'utc'::text),
    is_read integer not null default 0,
    is_deleted integer not null default 0,
    is_edited integer not null default 0,
    reply_message_username text null,
    reply_message_attachment_url text null,
    shared_post_id uuid null,
    constraint messages_pkey primary key (id),
    constraint check_participant foreign key (from_id, conversation_id) references participants (user_id, conversation_id) on update cascade on delete cascade,
    constraint messages_conversation_id_fkey foreign key (conversation_id) references conversations (id) on update cascade on delete cascade,
    constraint messages_reply_message_id_fkey foreign key (reply_message_id) references messages (id) on delete set null,
    constraint messages_shared_post_id_fkey foreign key (shared_post_id) references posts (id) on update cascade on delete set null,
    constraint messages_user_id_fkey foreign key (from_id) references profiles (id) on update cascade on delete cascade
  ) tablespace pg_default;

alter table messages enable row level security;

create policy "Everybody can see messages in the conversation." on public.messages
  for select using (true);

create policy "Only owner can update the message." on public.messages
  for update to authenticated with check (true);

create policy "Only authenticated users can create message in the conversations with other users." 
  on public.messages
    for insert to authenticated with check (true);

create policy "Only authenticated users can delete their own messages in the conversations they participate in." 
  on public.messages 
    for delete to authenticated using (auth.uid() = from_id);

create type attachment_type as enum('image', 'file', 'video', 'giphy', 'audio', 'url_preview');

create table
  public.attachments (
    id uuid not null default gen_random_uuid (),
    message_id uuid not null,
    title text null,
    text text null,
    title_link text null,
    image_url text null,
    thumb_url text null,
    author_name text null,
    author_link text null,
    asset_url text null,
    og_scrape_url text null,
    type attachment_type not null,
    constraint attachments_pkey primary key (id),
    constraint attachments_message_id_fkey foreign key (message_id) references messages (id) on update cascade on delete cascade
  ) tablespace pg_default;

alter table attachments enable row level security;

create policy "Everybody can see their messages' attachments." on public.attachments
  for select using (true);

create policy "Everybody can update their messages' attachments." on public.attachments
  for update using (true) with check (true);

create policy "Only authenticated users can add attachments." 
  on public.attachments
    for insert to authenticated with check (true);

create policy "Only owners can remove attachments." 
  on public.attachments 
    for delete to authenticated using (true);

create policy "Everybody can see their participation with conversations." on public.participants
  for select using (true);

create policy "Only authenticated users can participate in conversations." 
  on public.participants
    for insert to authenticated with check (true);

create policy "Only authentiaceted users can remove participation in conversations." 
  on public.participants 
    for delete to authenticated using (auth.uid() = user_id);
    
create type story_content_type as enum('image', 'video');

create table
  public.stories (
    id uuid not null default gen_random_uuid (),
    user_id uuid not null,
    content_type story_content_type not null,
    content_url text not null,
    duration integer null,
    created_at timestamp with time zone not null default (now() at time zone 'utc'::text),
    expires_at timestamp with time zone not null default (
      (now() at time zone 'utc'::text) + '1 day'::interval
    ),
    constraint stories_pkey primary key (id),
    constraint stories_user_id_fkey foreign key (user_id) references profiles (id) on update cascade on delete cascade
  ) tablespace pg_default;


alter table stories enable row level security;

create policy "Everybody can see each others stories." on public.stories
  for select using (true);

create policy "Only authenticated users can add stories."
  on public.stories
    for insert to authenticated with check (true);

create policy "Only owners can remove stories."
  on public.stories
    for delete to authenticated using (auth.uid() = user_id);
  
create policy "Only owners can update stories."
  on public.stories
    for update to authenticated using (auth.uid() = user_id);

-- Create PowerSync publication with all the existings tables ->
create publication powersync for all tables;

-- Create useful functions and triggers to manage storage objects and relevant data ->

create or replace function handle_delete_post_media () returns trigger as $$
BEGIN
  DELETE FROM storage.objects WHERE bucket_id = 'posts' AND (storage.foldername (name))[1] = OLD.id::text;
  RETURN OLD;
END;
$$ language plpgsql;

create trigger on_post_deleted
after delete on posts for each row
execute function handle_delete_post_media();

create or replace function clear_posts_objects () returns trigger as $$
begin
  delete from storage.objects where bucket_id = 'posts';
  return null;
end;
$$ language plpgsql;

create trigger clear_posts_trigger
after
truncate on public.posts for each statement
execute function clear_posts_objects ();

create or replace function clear_stories_objects () returns trigger as $$
begin
  delete from storage.objects where bucket_id = 'stories';
  return null;
end;
$$ language plpgsql;

create trigger clear_stories_trigger
after
truncate on public.stories for each statement
execute function clear_stories_objects ();

create or replace function handle_delete_story_media () returns trigger as $$
BEGIN
  DELETE FROM storage.objects WHERE bucket_id = 'stories' AND (storage.foldername (name))[1] = OLD.id::text;
  RETURN OLD;
END;
$$ language plpgsql;

create trigger on_story_deleted
after delete on stories for each row
execute function handle_delete_story_media();

create or replace function delete_storage_object(bucket text, object text, out status int, out content text)
 returns record
 language 'plpgsql'
 security definer
 as $$
 declare
   project_url text := '<PROJECT_URL>';
   service_role_key text := '<SERVICE_ROLE_KEY>'; -- full access needed
   delete_object text := reverse(split_part(reverse(object), '/', 1));
   url text := project_url||'/storage/v1/object/'||bucket||'/'||delete_object;
 begin
   select
       into status, content
            result.status::int, result.content::text
       FROM extensions.http((
     'DELETE',
     url,
     ARRAY[extensions.http_header('authorization','Bearer '||service_role_key)],
     NULL,
     NULL)::extensions.http_request) as result;
 end;
 $$;

 create or replace function delete_avatar(avatar_url text, out status int, out content text)
 returns record
 language 'plpgsql'
 security definer
 as $$
 begin
   select
       into status, content
            result.status, result.content
       from public.delete_storage_object('avatars', avatar_url) as result;
 end;
 $$;

 create or replace function delete_old_avatar()
 returns trigger
 language 'plpgsql'
 security definer
 as $$
 declare
   status int;
   content text;
   avatar_name text;
 begin
   if coalesce(old.avatar_url, '') <> ''
       and (tg_op = 'DELETE' or (old.avatar_url <> coalesce(new.avatar_url, ''))) then
     -- extract avatar name
     avatar_name := old.avatar_url;
     select
       into status, content
       result.status, result.content
       from public.delete_avatar(avatar_name) as result;
     if status <> 200 then
       raise warning 'Could not delete avatar: % %', status, content;
     end if;
   end if;
   if tg_op = 'DELETE' then
     return old;
   end if;
   return new;
 end;
 $$;

 create trigger before_profile_changes
   before update of avatar_url or delete on public.profiles
   for each row execute function public.delete_old_avatar();

 create or replace function delete_old_profile()
 returns trigger
 language 'plpgsql'
 security definer
 as $$
 begin
   delete from public.profiles where id = old.id;
   return old;
 end;
 $$;

 create trigger before_delete_user
   before delete on auth.users
   for each row execute function public.delete_old_profile();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email, username, avatar_url, push_token)
  values (
    new.id, 
    new.raw_user_meta_data->>'full_name', 
    new.email,
    new.raw_user_meta_data->>'username', 
    new.raw_user_meta_data->>'avatar_url',
    new.raw_user_meta_data->>'push_token'
    );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create or replace function public.handle_update_user() 
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  update public.profiles
  set full_name = new.raw_user_meta_data->>'full_name',
      email = new.email,
      username = new.raw_user_meta_data->>'username',
      avatar_url = new.raw_user_meta_data->>'avatar_url',
      push_token = new.raw_user_meta_data->>'push_token'
  where id = new.id;
  return new;
end;
$$;

create trigger on_auth_user_updated
after
update on auth.users for each row
execute procedure public.handle_update_user();