// ignore_for_file: deprecated_member_use

import 'package:app_ui/app_ui.dart';
import 'package:chats_repository/chats_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/bloc/app_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/chats/bloc/chats_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/chats/widgets/chat_inbox_tile.dart';
import 'package:go_router/go_router.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    return BlocProvider(
      create: (context) =>
          ChatsBloc(chatsRepository: context.read<ChatsRepository>())
            ..add(ChatsSubscriptionRequested(userId: user.id)),
      child: const ChatsView(),
    );
  }
}

class ChatsView extends StatelessWidget {
  const ChatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: CustomScrollView(
        slivers: [
          ChatsAppBar(),
          ChatsListView(),
        ],
      ),
    );
  }
}

class ChatsAppBar extends StatelessWidget {
  const ChatsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return SliverAppBar(
      centerTitle: false,
      pinned: true,
      scrolledUnderElevation: 0,
      title: Text(
        user.username ?? user.fullName ?? '',
        style: context.titleLarge?.copyWith(fontWeight: AppFontWeight.bold),
      ),
      actions: [
        Tappable(
          onTap: () async {
            final participantId =
                await context.pushNamed('search_users') as String?;
            if (participantId == null) return;
            await Future(
              () => context.read<ChatsBloc>().add(
                    ChatsCreateChatRequested(
                      userId: user.id,
                      participantId: participantId,
                    ),
                  ),
            );
          },
          child: const Icon(Icons.add,size: AppSize.iconSize),
        ),
      ],
    );
  }
}

class ChatsListView extends StatelessWidget {
  const ChatsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = context.select((ChatsBloc bloc) => bloc.state.chats);
    if (chats.isEmpty) return const ChatsEmpty();
    return SliverList.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ChatInboxTile(chat: chat);
      },
    );
  }
}

class ChatsEmpty extends StatelessWidget {
  const ChatsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.flip(
                flipX: true,
                child: Assets.icons.chatCircle
                    .svg(color: context.adaptiveColor, height: 86, width: 86),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No chats yet!',
                style: context.headlineLarge
                    ?.copyWith(fontWeight: AppFontWeight.semiBold),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                text: 'Start a Chat',
                onPressed: () async {
                  final participantId =
                      await context.pushNamed('search_users') as String?;
                  if (participantId == null) return;
                  await Future(
                    () => context.read<ChatsBloc>().add(
                          ChatsCreateChatRequested(
                            userId: user.id,
                            participantId: participantId,
                          ),
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
