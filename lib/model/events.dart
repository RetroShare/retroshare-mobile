import 'dart:async';

import "package:eventsource/eventsource.dart";

Map<RsEventType, StreamSubscription<Event>> rsEventsSubscriptions;

enum RsEventType{
  NONE,/// Used internally to detect invalid event type passed
  /// @see RsBroadcastDiscovery
  BROADCAST_DISCOVERY,
  /// @see RsDiscPendingPgpReceivedEvent
  GOSSIP_DISCOVERY,
  /// @see AuthSSL
  AUTHSSL_CONNECTION_AUTENTICATION,
  /// @see pqissl
  PEER_CONNECTION,
  /// @see RsGxsChanges, used also in @see RsGxsBroadcast
  GXS_CHANGES,
  /// Emitted when a peer state changes, @see RsPeers
  PEER_STATE_CHANGED,
  /// @see RsMailStatusEvent
  MAIL_STATUS,
  /// @see RsGxsCircleEvent
  GXS_CIRCLES,
  /// @see RsGxsChannelEvent
  GXS_CHANNELS,
  /// @see RsGxsForumEvent
  GXS_FORUMS,
  /// @see RsGxsPostedEvent
  GXS_POSTED,
  /// @see RsGxsPostedEvent
  GXS_IDENTITY,
  /// @see RsFiles
  SHARED_DIRECTORIES,
  /// @see RsFiles
  FILE_TRANSFER,
  /// @see RsMsgs
  CHAT_MESSAGE,
  MAX /// Used internally, keep last
}