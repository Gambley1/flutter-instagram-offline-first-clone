// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_bloc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatState _$ChatStateFromJson(Map<String, dynamic> json) => ChatState(
      status: $enumDecode(_$ChatStatusEnumMap, json['status']),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChatStateToJson(ChatState instance) => <String, dynamic>{
      'status': _$ChatStatusEnumMap[instance.status]!,
      'messages': instance.messages.map((e) => e.toJson()).toList(),
    };

const _$ChatStatusEnumMap = {
  ChatStatus.initial: 'initial',
  ChatStatus.loading: 'loading',
  ChatStatus.success: 'success',
  ChatStatus.failure: 'failure',
};
