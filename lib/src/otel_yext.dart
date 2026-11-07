// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_yext_suppression.dart';

const _tracerName = 'dartastic_otel_libs_yext';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class YextResult {
  /// Creates a result.
  const YextResult({
    this.accountId,
    this.entityKind,
    this.entityId,
    this.entityType,
    this.categoryIds,
    this.listingPublisherId,
    this.listingStatus,
    this.suggestionsPending,
    this.reviewId,
    this.reviewRating,
    this.experienceKey,
    this.queryId,
    this.searchResultsTotal,
    this.directAnswerType,
    this.spellChecked,
    this.statusCode,
  });

  /// Yext account id (multi-tenant brand).
  final String? accountId;

  /// `entity` / `listing` / `review` / `social_post` / `health_check`
  /// / `tag` / `folder` / `category` / `experience` / `query` /
  /// `suggestion` / `analytics_report`.
  final String? entityKind;

  final String? entityId;

  /// `LOCATION` / `RESTAURANT` / `HEALTHCARE_PROFESSIONAL` /
  /// `HEALTHCARE_FACILITY` / `ATM` / `EVENT` / `PRODUCT` / `JOB` /
  /// `FAQ` / `MENU_ITEM` / `BIO` / `INSURANCE_AGENT` / `HOTEL` /
  /// `FINANCIAL_PROFESSIONAL`.
  final String? entityType;

  /// Comma-separated Yext category ids (e.g., `4-restaurants`).
  final String? categoryIds;

  /// `GOOGLE_MY_BUSINESS` / `FACEBOOK` / `APPLE` / `BING` /
  /// `YELP` / `FOURSQUARE` / `MAPQUEST` / `WAZE` / `NAVMII` /
  /// `INFOBEL` / `TOMTOM` / `ALEXA` / `SIRI`.
  final String? listingPublisherId;

  /// `LIVE` / `IN_PROGRESS` / `NEEDS_REVIEW` / `OPTED_OUT` /
  /// `NOT_PROCESSED` / `CANCELLED`.
  final String? listingStatus;

  /// Number of suggestions queued waiting on the customer to
  /// approve/dismiss.
  final int? suggestionsPending;

  final String? reviewId;

  /// 1-5 stars.
  final int? reviewRating;

  /// Yext Answers experience id.
  final String? experienceKey;

  final String? queryId;

  /// Total search results across all verticals.
  final int? searchResultsTotal;

  /// Direct Answer kind (`FEATURED_SNIPPET` / `FIELD_VALUE` /
  /// `KNOWLEDGE_PANEL` / `GENERATIVE` — RAG-generated answer).
  final String? directAnswerType;

  /// `true` when Yext spell-corrected the user query.
  final bool? spellChecked;

  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class YextCallResult<T> {
  /// Creates a call result.
  const YextCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final YextResult? result;
}

/// Wraps a Yext API call in a CLIENT span. [operation] is one of
/// `entities.create`, `entities.update`, `entities.list`,
/// `entities.get`, `listings.list`, `listings.get`,
/// `listings.suggest`, `reviews.list`, `reviews.respond`,
/// `social_posts.create`, `answers.query`, `answers.universal_search`,
/// `answers.vertical_search`, `answers.autocomplete`,
/// `categories.list`, `analytics.events`.
Future<T> tracedYext<T>({
  required String operation,
  required Future<YextCallResult<T>> Function() invoke,
}) async {
  if (yextInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'yext',
    'rpc.method': operation,
    'yext.operation': operation,
  };

  final span = _tracer().startSpan(
    'yext $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.accountId != null) {
        extras.add(OTelAPI.attributeString(
          'yext.account.id',
          r.result!.accountId!,
        ));
      }
      if (r.result!.entityKind != null) {
        extras.add(OTelAPI.attributeString(
          'yext.entity.kind',
          r.result!.entityKind!,
        ));
      }
      if (r.result!.entityId != null) {
        extras.add(OTelAPI.attributeString(
          'yext.entity.id',
          r.result!.entityId!,
        ));
      }
      if (r.result!.entityType != null) {
        extras.add(OTelAPI.attributeString(
          'yext.entity.type',
          r.result!.entityType!,
        ));
      }
      if (r.result!.categoryIds != null) {
        extras.add(OTelAPI.attributeString(
          'yext.categories',
          r.result!.categoryIds!,
        ));
      }
      if (r.result!.listingPublisherId != null) {
        extras.add(OTelAPI.attributeString(
          'yext.listing.publisher_id',
          r.result!.listingPublisherId!,
        ));
      }
      if (r.result!.listingStatus != null) {
        extras.add(OTelAPI.attributeString(
          'yext.listing.status',
          r.result!.listingStatus!,
        ));
        if (r.result!.listingStatus == 'NEEDS_REVIEW' ||
            r.result!.listingStatus == 'CANCELLED') {
          span.setStatus(
            SpanStatusCode.Error,
            'Yext listing ${r.result!.listingStatus}',
          );
        }
      }
      if (r.result!.suggestionsPending != null) {
        extras.add(OTelAPI.attributeInt(
          'yext.suggestions.pending',
          r.result!.suggestionsPending!,
        ));
      }
      if (r.result!.reviewId != null) {
        extras.add(OTelAPI.attributeString(
          'yext.review.id',
          r.result!.reviewId!,
        ));
      }
      if (r.result!.reviewRating != null) {
        extras.add(OTelAPI.attributeInt(
          'yext.review.rating',
          r.result!.reviewRating!,
        ));
      }
      if (r.result!.experienceKey != null) {
        extras.add(OTelAPI.attributeString(
          'yext.experience.key',
          r.result!.experienceKey!,
        ));
      }
      if (r.result!.queryId != null) {
        extras.add(OTelAPI.attributeString(
          'yext.query.id',
          r.result!.queryId!,
        ));
      }
      if (r.result!.searchResultsTotal != null) {
        extras.add(OTelAPI.attributeInt(
          'yext.search.results_total',
          r.result!.searchResultsTotal!,
        ));
      }
      if (r.result!.directAnswerType != null) {
        extras.add(OTelAPI.attributeString(
          'yext.direct_answer.type',
          r.result!.directAnswerType!,
        ));
      }
      if (r.result!.spellChecked != null) {
        extras.add(OTelAPI.attributeBool(
          'yext.spell_checked',
          r.result!.spellChecked!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Yext HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
