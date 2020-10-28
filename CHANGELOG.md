# [Main]

### Fixed

- [Changed behavior of `scrollInsets` (now `scrollIndicatorInsets`)](https://github.com/kyleve/Listable/pull/222), which now only affects the scroll indicator insets of the contained scroll view, and does **not** affect the content inset of the scroll view. Please using `padding`, etc, on the various list layout types instead to control visual padding.

- [Ensure we respect both `frame` and `bounds` changes](https://github.com/kyleve/Listable/pull/227) to update the inner `CollectionView`'s frame. We previously used to only respect `frame` changes, but we should also respect `bounds` changes, as these are used by auto layout.

- [Fix support for `autolayout` items and headers/footers](TODO) by ensuring we pass through the correct `systemLayoutSizeFitting` calls to content. Add assertions that measured sizing is within a reasonable bound.

### Added

- [Introduce `onSelectionChanged` on `ListStateObserver`](https://github.com/kyleve/Listable/pull/223) to allow observing when the selected rows change.

### Removed

### Changed

### Misc

# Past Releases

# [0.11.0] - 2020-10-20

### Added

- Allow [setting the `sizing` type on a `List`](https://github.com/kyleve/Listable/pull/202). This controls how the list should be sized by Blueprint: Should it take up all allowed space, or should it size to fit based on its content.

# [0.10.1] - 2020-10-01

- [Fixed import](https://github.com/kyleve/Listable/pull/215) of Swift bridging header, so Cocoapods can build with or without `use_frameworks!`.

# [0.10.0] - 2020-09-24

### Fixed

- [Adjust calculated keyboard inset in both `setFrame` and `layoutSubviews`](https://github.com/kyleve/Listable/pull/200). This resolves issues that can occur if the list frame changes while the keyboard is visible.

### Added

- [Add support for `onInsert` , `onRemove`, `onMove`, `onUpdate`, on `Item`](https://github.com/kyleve/Listable/pull/196) to track when when items are added, removed, moved, or updated. Changed `onContentChanged` to `onContentUpdated` on `ListStateObserver`; it is always called during updates; you can check the `hadChanges` property.

### Removed

- [Removed support for iOS 10](https://github.com/kyleve/Listable/pull/209). Future releases will only support iOS 11 and later.

### Changed

- [Change how keyboard are observed](https://github.com/kyleve/Listable/pull/199) to avoid a pitfall where the keyboard would not be accounted for if a `ListView` is created while a keyboard is already on screen. To avoid this problem, we switch to a globally shared `KeyboardObserver` which is loaded at app startup time.

- [`isEmpty` on `Content` and `Section` have been replaced with `contains(any:)`](https://github.com/kyleve/Listable/pull/197), which allows more granular comparison of the content in the whole list and in individual sections, respectively. This allows you to check if the list or sections contain headers, footers, items, all, or some combination of them.

- Listable has been [renamed to ListableUI](https://github.com/kyleve/Listable/pull/211/), and BlueprintLists is now named BlueprintUILists. This is done to be more consistent with other Square UI libraries, and to avoid a conflict with an existing published Cocoapod, also named Listable.

# 0.9.0 - Internal Only

### Added

- [Add `ListScrollPositionInfo` to all `ListStateObserver` callbacks](https://github.com/kyleve/Listable/pull/191).

### Changed

- [Simplify `Sizing` now that enums support default associated values.](https://github.com/kyleve/Listable/pull/189). Now instead of separate `.thatFits` and `.thatFitsWith(Constraint)` enums, there is a single `.thatFits(Constraint = .noConstraint)` case (the same applies for `autolayout`).

- Changed [how `zIndexes` are assigned to header and items, and support tapping headers / footers](https://github.com/kyleve/Listable/pull/193). This allows registering an `onTap` handler for any HeaderFooter, and providing a background to display while the tap's press is active.

## 0.8.0 - Internal Only

### Added

- [Add support for `ListStateObserver`](https://github.com/kyleve/Listable/pull/183) so that you can observe changes made to the list such as insertions, removals, scroll events, etc.

- [Add support for `ListActions`](https://github.com/kyleve/Listable/pull/183) which allows performing actions on the underlying list view when used in a declarative environment, or when you otherwise do not have access to the underlying view instance (`ListStateViewController`).

- Add support for [Behavior.KeyboardAdjustmentMode](https://github.com/kyleve/Listable/pull/166), which allows for disabling automatic keyboard adjustment behavior. This is useful if your container view is managing the size of or insets on a `ListView` itself.

- [Introduced `callAsFunction` support](https://github.com/kyleve/Listable/pull/181) when building with Xcode 11.4 or later. This allows you to replace code like this:

  ```
  List { list in
      list += Section("first") { section in ... }
  }
  ```
  
  With this:
  
  ```
  List { list in
      list("first") { section in ... }
  }
  ```
  
  Improving terseness when building sections in a list.

- [`.paged()` is now a supported layout type.](https://github.com/kyleve/Listable/pull/178) This allows implementing your list to render similarly to a `UIPageViewController`, in either horizontal or vertical alignment.  
  

### Removed

- [Removed support for .`horiztonal` layouts](https://github.com/kyleve/Listable/pull/178) on `.list()` layouts. Now only `.vertical` is supported (this could return at a later date if needed).

### Changed

- [Changed `Section` initialization APIs](https://github.com/kyleve/Listable/pull/181) from `Section(identifier: "my-id") { ... }` to `Section("my-id") { ... }` – it's clear from the API what the first param is for, so the param name just made callsites longer.

- [Renamed `setContent` and `setProperties`](https://github.com/kyleve/Listable/pull/178) methods on `ListView` to `configure`.

- [Significant refactors to how the custom layout APIs work.](https://github.com/kyleve/Listable/pull/178) While this is mostly an internal concern, it continues to refine these APIs to set them up for public exposure and usage at a later date to customize layouts.

## 0.7.0 - Internal Only

### Fixed

- [Significant performance improvements](https://github.com/kyleve/Listable/pull/179) for list updates which contain either no changes, or only in-place updates to existing items and sections. In many cases, these updates will now be 80% faster. This change also improves performance for other types of changes such as insertions, removals, or moves, but not to the same degree.

### Added

- [Added additional layout configuration options](https://github.com/kyleve/Listable/pull/173/): `headerToFirstSectionSpacing` and `lastSectionToFooterSpacing` now let you control the spacing between the list header and content, and the content and the list footer.

- [Add support for snapshot testing `Item`s](https://github.com/kyleve/Listable/pull/171) via the `ItemPreviewView` class. This is a view type which takes in some configuration options, and an `Item`, which you can then use in snapshot tests to verify the appearance of your `Item` and `ItemContent` .

  ```
  let view = ItemPreviewView()
          
  view.update(
      with: 300.0,
      state: .init(isSelected: false, isHighlighted: false),
      item: Item(MyItemContent(...))
  )

  self.takeSnapshot(of: view)
  ```

- [Add support for Xcode previews](https://github.com/kyleve/Listable/pull/171) via the `ItemPreview` type. This allows easy previewing your `ItemContent` during development like so:

  ```
  struct ElementPreview : PreviewProvider {
      static var previews: some View {
          ItemPreview.withAllItemStates(
              for: Item(XcodePreviewDemoContent(
                  text: "Lorem ipsum dolor sit amet (...)"
              ))
          )
      }
  }
  ```
  
  There are included options like `withAllItemStates` which allow seeing previews across the various possible selection and highlight states.

- Add `customInterSectionSpacing` property to `Section.Layout` which allows the user to specify [custom spacing after a section](https://github.com/kyleve/Listable/pull/172), overriding the calculated spacing.

- [Add `insertAndRemoveAnimations` to `Item`](https://github.com/kyleve/Listable/pull/176) to allow customizing the animations used when an `Item` is inserted or removed from a list. Note that customizing this option when responding to `SwipeActions` will come at a later date.

- [Add `ListViewController`](https://github.com/kyleve/Listable/pull/176) make it easy to create view controllers backed by a Listable `ListView`.

### Removed

### Changed

- Update `Item` callbacks to [allow for providing more info to the callback parameters](https://github.com/kyleve/Listable/pull/160).

- [`ListAppearance.Layout.padding` is now applied around all content in the list](https://github.com/kyleve/Listable/pull/173/), not only around sections. To regain the previous behavior, use `headerToFirstSectionSpacing` and `lastSectionToFooterSpacing`.

- Significantly change how [layout configuration is done](https://github.com/kyleve/Listable/pull/174) to make it clearer which type of layout is currently in use, and which options are available on which layouts.

  Previously, to configure a layout, you would write code like this:

  ```
  list.appearance.layoutType = .list
  list.appearance.list.layout.padding = UIEdgeInsets(...)
  ```

  Now, you configure the layout like this:

  ```
  list.layout = .list {
    $0.layout.padding = UIEdgeInsets(...)
  }
  ```

  Or, for your custom layouts, like this:

  ```
  list.layout = MyCustomLayout.describe {
    $0.myLayoutsProperty = .foo
  }
  ```

### Misc

## 0.6.1 - Internal Only

### Changed

- Change `Item`'s `onSelect` and `onDeselect` [to be performed asynchronously](https://github.com/kyleve/Listable/pull/155) after a single runloop spin, to give `UICollectionView` time to schedule animations if these callbacks are slow.
- Add improved signpost logging for selection and deselection, to more easily identify slow callbacks.

## 0.6.0 - Internal Only

### Fixed

- Fixed [multiple selection and highlight issues](https://github.com/kyleve/Listable/pull/153): Highlighting cells now only occurs if the `selectionStyle` is `tappable` or `selectable`. Ensure that when `tappable` is provided, the content of a cell is updated when the cell is deselected.

### Added

- Added type aliases for `HeaderFooter` and `HeaderFooterContent` to reduce verbosity of use. Now instead of typing `HeaderFooter(MyHeader())`, you can use `Header(MyHeader())`.
- Replace unused / experimental `Binding` type [with `Coordinator`](https://github.com/kyleve/Listable/pull/143), which allows you to independently manage item state in a similar manner to SwiftUI's `UIViewRepresentable`'s `Coordinator`.

### Removed

### Changed

- **Major Change:** `ItemElement` and `HeaderFooterElement` [were renamed to `ItemContent` and `HeaderFooterContent`](https://github.com/kyleve/Listable/pull/150), respectively. This is intended to be a clearer indicaton as to what they are for (the content of an item or header/footer), and fixes a name collision with Blueprint, where we overloaded the meaning of `Element` when using Blueprint integration via `BlueprintUILists`.
- Changed `BlueprintHeaderFooter{Content/Element}`'s main method to be `elementRepresentation` instead of `element`. This allows easier conformance of `BlueprintUI.ProxyElement` types to `BlueprintHeaderFooter{Content/Element}`.
- `SelectionMode` [was moved from `Content` to `Behavior`](https://github.com/kyleve/Listable/pull/152), which is in line with other collection view behaviours like scrolling and underflow.
- Rename `ItemSelectionStyle.none` to `ItemSelectionStyle.notSelectable`. This is to avoid conflicts with `Optional.none` when working with `ItemSelectionStyle` as an `Optional`.

## 0.5.0 - Internal Only

### Added

- Added support for [conditionally scrolling to items](https://github.com/kyleve/Listable/pull/129) on insert, based on the `shouldPerform` block passed to the `AutoScrollAction`.

## Earlier - Internal Only

Earlier releases were ad-hoc and not tracked. To see all changes, please reference [closed PRs on Github](https://github.com/kyleve/Listable/pulls?q=is%3Apr+is%3Aclosed).


[Main]: https://github.com/square/Blueprint/compare/0.11.0...HEAD
[0.11.0]: https://github.com/square/Blueprint/compare/0.10.1...0.11.0
[0.10.1]: https://github.com/square/Blueprint/compare/0.10.0...0.10.1
[0.10.0]: https://github.com/square/Blueprint/compare/0.9.0...0.10.0
