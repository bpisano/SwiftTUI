# Performance Baseline - SwiftTUIRuntime Extraction

## Run Metadata

| Field | Value |
| --- | --- |
| Repository | `SwiftTUI` |
| Date | `2026-04-28` |
| Command | `swift test --filter 'HStackPerformanceTests|VStackPerformanceTests|PerformanceBenchmarkTests'` |
| Platform | `arm64e-apple-macos14.0` |
| Result | `33 benchmark tests passed` |

## Suite Summary

| Suite | Tests | Result | Suite Duration |
| --- | ---: | --- | ---: |
| `HStackPerformanceTests` | 11 | Pass | `3.032 s` |
| `PerformanceBenchmarkTests` | 11 | Pass | `0.469 s` |
| `VStackPerformanceTests` | 11 | Pass | `2.868 s` |

## Layout Benchmarks

| Suite | Test | Avg Wall Time (s) | RSD % |
| --- | --- | ---: | ---: |
| `HStack` | `testPerformance_1024Fixed` | `0.001` | `13.019` |
| `HStack` | `testPerformance_1024Mixed` | `0.001` | `4.826` |
| `HStack` | `testPerformance_128Fixed` | `0.000` | `16.761` |
| `HStack` | `testPerformance_16Fixed` | `0.000` | `73.262` |
| `HStack` | `testPerformance_16Mixed` | `0.000` | `67.403` |
| `HStack` | `testPerformance_256Fixed` | `0.001` | `92.120` |
| `HStack` | `testPerformance_256Mixed` | `0.001` | `28.160` |
| `HStack` | `testPerformance_4Fixed` | `0.000` | `137.692` |
| `HStack` | `testPerformance_512Fixed` | `0.001` | `77.059` |
| `HStack` | `testPerformance_64Fixed` | `0.000` | `95.578` |
| `HStack` | `testPerformance_64Mixed` | `0.000` | `19.743` |
| `VStack` | `testPerformance_1024Fixed` | `0.001` | `47.811` |
| `VStack` | `testPerformance_1024Mixed` | `0.001` | `82.834` |
| `VStack` | `testPerformance_128Fixed` | `0.000` | `17.639` |
| `VStack` | `testPerformance_16Fixed` | `0.000` | `197.263` |
| `VStack` | `testPerformance_16Mixed` | `0.000` | `60.320` |
| `VStack` | `testPerformance_256Fixed` | `0.001` | `80.466` |
| `VStack` | `testPerformance_256Mixed` | `0.000` | `36.084` |
| `VStack` | `testPerformance_4Fixed` | `0.000` | `106.353` |
| `VStack` | `testPerformance_512Fixed` | `0.001` | `84.727` |
| `VStack` | `testPerformance_64Fixed` | `0.000` | `35.676` |
| `VStack` | `testPerformance_64Mixed` | `0.000` | `117.627` |

## AttributeGraph Clock Benchmarks

| Test | Avg Clock Time (s) | Clock RSD % |
| --- | ---: | ---: |
| `testBinaryTree1024LeavesInitialEvaluation` | `0.000` | `74.700` |
| `testBinaryTree1024LeavesReEvaluationAfterSourceChange` | `0.009` | `4.212` |
| `testDeepChain1000InitialEvaluation` | `0.000` | `11.831` |
| `testDeepChain1000NoOpWrite` | `0.000` | `59.673` |
| `testDeepChain1000ReEvaluationAfterSourceChange` | `0.003` | high variance |
| `testMultiDiamond64x8InitialEvaluation` | `0.000` | high variance |
| `testMultiDiamond64x8ReEvaluationAfterSourceChange` | `0.002` | `5.571` |
| `testPendingCut1000DownstreamNodesSkippedAfterNoOpClamp` | `0.001` | `1.591` |
| `testSharedNodeEvaluatedOnceAcross500Dependents` | `0.002` | `6.767` |
| `testWideFanOut5000InitialEvaluation` | `0.001` | `1.518` |
| `testWideFanOut5000ReEvaluationAfterSourceChange` | `0.012` | `2.923` |

## Comparison Notes

| Topic | Note |
| --- | --- |
| Comparison target | `Docs/Performance/2026-04-25-keyboard-input-baseline.md` |
| Result | `33/33 benchmark tests passed` |
| Runtime extraction | No layout or AttributeGraph hot-path code changed; only target ownership and public launcher moved. |
| Layout wall-clock | No actionable regression. Small layout benchmarks stay sub-millisecond and several rows have high RSD from warm-up outliers. |
| AttributeGraph clock | No runtime-related hot-path change. Final `WideFanOut5000ReEvaluation` rounded to `0.012 s`, matching previous baseline. |
