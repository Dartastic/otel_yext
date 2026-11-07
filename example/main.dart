// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_yext/otel_yext.dart';

/// Traces Yext calls with OpenTelemetry.
///
/// `otel_yext` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Yext call in
/// [tracedYext]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'yext-example');

  // Wraps a Yext API call in a CLIENT span.
  final yextId = await tracedYext<String>(
    operation: 'entities.create',
    invoke: () async {
      // Make the Yext call here, then report what it returned.
      const id = 'yext_8f3a2c';
      return const YextCallResult(
          value: id,
          result: YextResult(
              accountId: 'account_8f3a2c',
              entityKind: 'listing',
              entityId: 'entity_8f3a2c',
              entityType: 'LOCATION',
              categoryIds: '4-restaurants',
              listingPublisherId: 'GOOGLE_MY_BUSINESS',
              listingStatus: 'LIVE',
              suggestionsPending: 1,
              reviewId: 'review_8f3a2c',
              reviewRating: 1,
              experienceKey: 'orders/2026/inv-1042.pdf',
              queryId: 'query_8f3a2c',
              searchResultsTotal: 1,
              directAnswerType: 'FEATURED_SNIPPET',
              spellChecked: true,
              statusCode: 201));
    },
  );
  OTelLog.info('tracedYext entities.create returned $yextId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutYextInstrumentationAsync.
  await runWithoutYextInstrumentationAsync(
    () => tracedYext<String>(
      operation: 'entities.create',
      invoke: () async {
        const id = 'yext_8f3a2c';
        return const YextCallResult(
            value: id,
            result: YextResult(
                accountId: 'account_8f3a2c',
                entityKind: 'listing',
                entityId: 'entity_8f3a2c',
                entityType: 'LOCATION',
                categoryIds: '4-restaurants',
                listingPublisherId: 'GOOGLE_MY_BUSINESS',
                listingStatus: 'LIVE',
                suggestionsPending: 1,
                reviewId: 'review_8f3a2c',
                reviewRating: 1,
                experienceKey: 'orders/2026/inv-1042.pdf',
                queryId: 'query_8f3a2c',
                searchResultsTotal: 1,
                directAnswerType: 'FEATURED_SNIPPET',
                spellChecked: true,
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
