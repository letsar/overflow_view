## Unreleased
### Added
* [Wrapped items](https://github.com/letsar/overflow_view/issues/2): `maxRuns` and `runSpacing` display the children in several runs, with the overflow indicator at the end of the last one.

### Changed
* `OverflowView.flexible` no longer builds the overflow indicator when all the children fit.
* `OverflowView.flexible` only clips its children when they overflow.

### Fixed
* `OverflowView.flexible` positions the overflow indicator with its final size when it changes with the number of hidden children.
* Children which exactly fill the available space are no longer hidden because of rounding errors.

## 0.5.1
### Fixed
* [Hit test always returns false.](https://github.com/letsar/overflow_view/issues/10)

## 0.5.0
### Changed
* Update Flutter constraints.
* Update version of value_layout_builder.
  
### Fixed
* Flutter 3.32 breaking changes issue.

## 0.4.0
### Changed
* Update Flutter and Dart SDK constraints.
* Update dependencies.

## 0.3.1
### Changed
* Small formatting issues.

## 0.3.0
### Changed
* Add support for null-safety.
* Increase the minimum version of Flutter.
* Increase the minimum version of dart sdk.

## 0.2.2
### Fixed
* [Issue when rendering overflow indicator after having displayed it once.](https://github.com/letsar/overflow_view/issues/3)

## 0.2.1
### Changed
* The parameter `spacing` can be negative to achieve a stacked effect.

## 0.2.0
### Added
* An `OverflowView.flexible` constructor to let children determine their own size.

## 0.1.0
* Initial Open Source release.
