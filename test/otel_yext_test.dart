// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_yext/otel_yext.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_yext-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('listings.list records publisher + status', () async {
    await tracedYext<String>(
      operation: 'listings.list',
      invoke: () async => const YextCallResult(
        value: 'ok',
        result: YextResult(
          accountId: 'acc_1',
          entityType: 'LOCATION',
          listingPublisherId: 'GOOGLE_MY_BUSINESS',
          listingStatus: 'LIVE',
          categoryIds: '4-restaurants,162-cafes',
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('yext listings.list')!);
    expect(a['yext.entity.type'], 'LOCATION');
    expect(a['yext.listing.publisher_id'], 'GOOGLE_MY_BUSINESS');
    expect(a['yext.listing.status'], 'LIVE');
    expect(a['yext.categories'], '4-restaurants,162-cafes');
  });

  test('NEEDS_REVIEW listing sets span error', () async {
    await tracedYext<String>(
      operation: 'listings.get',
      invoke: () async => const YextCallResult(
        value: 'ok',
        result: YextResult(
          listingPublisherId: 'APPLE',
          listingStatus: 'NEEDS_REVIEW',
          suggestionsPending: 3,
        ),
      ),
    );
    expect(
      spans.findSpanByName('yext listings.get')!.status,
      SpanStatusCode.Error,
    );
  });

  test('answers.universal_search records direct answer type', () async {
    await tracedYext<String>(
      operation: 'answers.universal_search',
      invoke: () async => const YextCallResult(
        value: 'ok',
        result: YextResult(
          experienceKey: 'help-site',
          queryId: 'q_1',
          searchResultsTotal: 42,
          directAnswerType: 'GENERATIVE',
          spellChecked: true,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('yext answers.universal_search')!);
    expect(a['yext.search.results_total'], 42);
    expect(a['yext.direct_answer.type'], 'GENERATIVE');
    expect(a['yext.spell_checked'], true);
  });

  test('suppression skips spans', () async {
    await runWithoutYextInstrumentationAsync(() async {
      await tracedYext<String>(
        operation: 'entities.list',
        invoke: () async => const YextCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('yext '), isEmpty);
  });
}
