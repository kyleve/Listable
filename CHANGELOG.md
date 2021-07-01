# [Main]

### Fixed

### Added

### Removed

### Changed

- [Update the `scrollIndicatorInsets` type](https://github.com/kyleve/Listable/pull/269) to `ListEdgeInsets`, which is similar to `UIEdgeInsets`, but each property is optional, allowing us to more correctly choose and override applied insets. This change also introduces `contentInsets` on `ListView`, which does the same thing, but for the underlying `contentInset` on the `UICollectionView`.

### Misc

# Past Releases

# [0.23.0] - 2021-06-29

### Added

- [Introduce `defaultHeaderFooterProperties` on `HeaderFooterContent`](https://github.com/kyleve/Listable/pull/304), to allow specifying default values for a `HeaderFooter` when values are not passed to the initializer.

# [0.22.2] - 2021-06-23

### Fixed

- Fixed `identifier(for:)` on `Section` to match name of `identifier(with:)` on `ItemContent`.

# [0.22.1] - 2021-06-22

### Fixed

- Fixed `Identifiable` conformance for `ItemContent`.

# [0.22.0] - 2021-06-22

### Misc

- Listable now depends on Blueprint `0.27.0` which has major breaking changes. There are no public changes to Listable, except public interfaces determined by Blueprint protocol conformance.

# [0.21.0] - 2021-06-17

### Fixed

- [When applying an update to visible views during content updates, the update now occurs within an animation block](https://github.com/kyleve/Listable/pull/292). This allows your view to inherit implicit animations more easily.

### Added

- [Reordering between multiple sections is now supported](https://github.com/kyleve/Listable/pull/292).
- [Introduced type safe access to `Section` content following reorder events](https://github.com/kyleve/Listable/pull/292). See `Section.filtered`.
- [`ListStateObserver.onItemReordered` was added](https://github.com/kyleve/Listable/pull/292) to observe reorder events at a list-wide level.
- [`ListLayout` was extended](https://github.com/kyleve/Listable/pull/292) to allow customization of in-progress moves. Note that `ListLayout` is not yet public.

### Changed

- [`Reordering` has been renamed to `ItemReordering`, and a new `SectionReordering` has been introduced](https://github.com/kyleve/Listable/pull/292). This allows finer-grained control over validating reorder events at both the item level and section level.
- [`ListReorderGesture` and `ItemReordering.GestureRecognizer` have been heavily refactored](https://github.com/kyleve/Listable/pull/292) to reduce visibility of internal state concerns.
- [`Item.identifier` has been renamed to `Item.anyIdentifier`](https://github.com/kyleve/Listable/pull/292). The new `Item.identifier` property is now a fully type safe identifier.
- [`ReorderingActions` was refactored](https://github.com/kyleve/Listable/pull/292) to expose less public state and ease use in UIView-backed list elements.
- [`Identifier<Represented>` is now `Identifier<Represented, Value>`; eg `Identifier<MyContent, UUID>`](https://github.com/kyleve/Listable/pull/292). This is done to support reacting to reordering events in a more type safe manner, and to make `Identifier` creation more type safe. This is a large breaking change.
- [Changed how `identifier`s for `ItemContent` are represented](https://github.com/kyleve/Listable/pull/292). `ItemContent` now returns a an identifier of a specific `IdentifierValue` (eg, `String`, `UUID`, etc), which is then assembled into an `Identifier` by the containing item. Additional APIs have been added for creating `Identifier`s in a more type safe manner. This is a large breaking change.

### Misc

- [The Blueprint-based shortcuts to create inline items and header footers have been renamed to `ElementItem` and `ElementHeaderFooter`](https://github.com/kyleve/Listable/pull/292).

# [0.20.2] - 2021-04-19

### Fixed

- [Fixed the spacing between the header and the first section of a `TableListLayout`](https://github.com/kyleve/Listable/pull/289) to not add the top padding.

# [0.20.1] - 2021-04-06

### Fixed

- [`TableListLayout` now maintains padding by default and with center alignments.](https://github.com/kyleve/Listable/pull/286)

# [0.20.0] - 2021-03-29

### Changed

- [Changed how `ListView.contentSize` is implemented](https://github.com/kyleve/Listable/pull/283) in order to improve performance. An internal list is no longer used, instead we create a layout and ask it to lay out its elements. `ListSizing` also moved to `BlueprintUILists`, as that is the only place it was used. 

# [0.19.0] - 2021-03-22

### Added
- [Add support for adjusting the content offset](https://github.com/kyleve/Listable/pull/281) when the refresh control becomes visible with the `offsetAdjustmentBehavior` property.

Example usage:

```
list.content.refreshControl = RefreshControl(
    isRefreshing: isRefreshing,
    offsetAdjustmentBehavior: .displayWhenRefreshing(animate: true, scrollToTop: true),
    onRefresh: onRefresh
)
```

# [0.18.0] - 2021-03-12

### Fixed

- When calling `scrollToItem` with a `.top` scroll position, [the item no longer appears underneath sticky section headers](https://github.com/kyleve/Listable/pull/279). 

### Added

- [Adds `scrollToSection`](https://github.com/kyleve/Listable/pull/277) to `ListActions` and `ListView`. To support this functionality, `Section` can now be queried with an `Identifier`. Also added `SectionPosition` to specify the top or bottom within a `Section`. 

Example usage:

```
listActions.scrolling.scrollToSection(
  with: MyItem.identifier(with: id),
  sectionPosition: .top,
  scrollPosition: ScrollPosition(position: .centered)
)
```

# [0.17.0] - 2021-03-10

### Fixed

- [When swiping to delete](https://github.com/kyleve/Listable/pull/270), limit overscrolling to 20% of the cell width. This prevents undesirable visual state while maintaining swipe bounciness. Additionally, ignore initial swipes to the right which do not "open" the cell.

- [Fixed a crash that occurred](https://github.com/kyleve/Listable/pull/271) when the list's width or height would become zero.

### Changed

- [Updates to `ItemContentCoordinator`](https://github.com/kyleve/Listable/pull/274) to properly support animations in Blueprint-backed rows. This change also generalizes the contained animation type to `ViewAnimation`, for use in both scrolling and content updates.

# [0.16.0] - 2021-02-08

### Fixed

- [When updating `contentInset`, retain the values pulled from the `CollectionView`](https://github.com/kyleve/Listable/pull/267). This is to avoid clobbering the content inset potentially set by other things like navigation controllers. 

### Changed

- [Rename `build` parameters to `configure`](https://github.com/kyleve/Listable/pull/262), in order to be more consistent within the framework and with Blueprint.

# [0.15.1] - 2021-01-25

### Fixed

- [Fix a memory leak in `ListView`](https://github.com/kyleve/Listable/pull/263) that caused all `ListViews` with content in them to leak.

# [0.15.0] - 2021-01-22

### Added

- [Introduce support for layout customization for `Item`, `HeaderFooter`, and `Section`](https://github.com/kyleve/Listable/pull/257) for all `ListLayout` types, not just `.table`.

- [Add `inserted` and `removed` items to `.onContentChanged`](https://github.com/kyleve/Listable/pull/260), to easily determine what content was added or removed from the list a central location.

### Changed

- [Rename `.list` layout to `.table`](https://github.com/kyleve/Listable/pull/258), which is clearer, and also reduces confusion between `ListLayout` (the base protocol for layouts), and the specific table-type layout.

# [0.14.2] - 2021-01-21

### Fixed

- `SwipeActionsConfiguration.performsFirstActionWithFullSwipe` is now respected when set to `false`.

# [0.14.1] - 2021-01-06

### Fixed

- [Ensure that `ItemContent`s and `HeaderFooter`s are a value type](https://github.com/kyleve/Listable/pull/243). This is generally assumed by Listable, but was previously not validated. This is only validated in `DEBUG` builds, to avoid otherwise affecting performance. 

- [Fix a regression](https://github.com/kyleve/Listable/pull/246/) that caused content to be re-measured during each application of an `Appearance`, even if the new `Appearance` was equal.

### Added

- [Adds a way to create items or header/footers](https://github.com/kyleve/Listable/pull/206) for Blueprint lists without requiring the creation of a `BlueprintItemContent` or `BlueprintHeaderFooterContent`.

# [0.13.0] - 2020-12-14

### Added

- [Introduce `LocalizedItemCollator`](https://github.com/kyleve/Listable/pull/236), a list-friendly version of `UILocalizedIndexedCollation` which allows collating a list of content at one time.

# [0.12.1] - 2020-12-01

### Fixed

- [Fixed frame setting calcuations, and fixed building in Xcode 11](https://github.com/kyleve/Listable/pull/234).

# [0.12.0] - 2020-12-01

### Fixed

- [Changed behavior of `scrollInsets` (now `scrollIndicatorInsets`)](https://github.com/kyleve/Listable/pull/222), which now only affects the scroll indicator insets of the contained scroll view, and does **not** affect the content inset of the scroll view. Please using `padding`, etc, on the various list layout types instead to control visual padding.

- [Ensure we respect both `frame` and `bounds` changes](https://github.com/kyleve/Listable/pull/227) to update the inner `CollectionView`'s frame. We previously used to only respect `frame` changes, but we should also respect `bounds` changes, as these are used by auto layout.

- [Fix support for `autolayout` items and headers/footers](https://github.com/kyleve/Listable/pull/228) by ensuring we pass through the correct `systemLayoutSizeFitting` calls to content. Add assertions that measured sizing is within a reasonable bound.

- [`Appearance.backgroundColor` now respects the current `UITraitCollection.userInterfaceStyle`](https://github.com/kyleve/Listable/pull/231). This means that the background color will default to `white` in light mode, and `black` in dark mode.

- [Update `ListView.contentSize(in:for:)` to properly validate the provided `fittingSize`](https://github.com/kyleve/Listable/pull/232). This ensures that `.unconstrained` measurements along the wrong axis will now assert; instead of freeze.

### Added

- [Introduce `onSelectionChanged` on `ListStateObserver`](https://github.com/kyleve/Listable/pull/223) to allow observing when the selected rows change.

- [Pass through `BlueprintUI.Environment` to the `Element`s being rendered from `BlueprintItemContent` and `BlueprintHeaderFooterContent`](https://github.com/kyleve/Listable/pull/225). This ensures that the content you put into a `List` respects the `BlueprintUI.Environment` of the `List` itself. This PR also introduces `ListEnvironment` to facilitate this, which allows similar passthrough of environment variables within Listable. 

- [Add a `didPerform` callback to `AutoScrollAction`](https://github.com/kyleve/Listable/pull/229), which allows registering a callback when an auto scroll action occurs.

- [Change `animated` option on scrolling to an `animation` option`](https://github.com/kyleve/Listable/pull/229), to allow customizing the animation's behavior.


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

- [Removed support for .`horiztonal` layouts](https://github.com/kyleve/Listable/pull/178) on `.table()` layouts. Now only `.vertical` is supported (this could return at a later date if needed).

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
  list.appearance.layoutType = .table
  list.appearance.table.layout.padding = UIEdgeInsets(...)
  ```

  Now, you configure the layout like this:

  ```
  list.layout = .table {
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


[Main]: https://github.com/kyleve/Listable/compare/0.23.0...HEAD
[0.23.0]: https://github.com/kyleve/Listable/compare/0.22.2...0.23.0
[0.22.2]: https://github.com/kyleve/Listable/compare/0.22.1...0.22.2
[0.22.1]: https://github.com/kyleve/Listable/compare/0.22.0...0.22.1
[0.22.0]: https://github.com/kyleve/Listable/compare/0.21.0...0.22.0
[0.21.0]: https://github.com/kyleve/Listable/compare/0.20.2...0.21.0
[0.20.2]: https://github.com/kyleve/Listable/compare/0.20.1...0.20.2
[0.20.1]: https://github.com/kyleve/Listable/compare/0.20.0...0.20.1
[0.20.0]: https://github.com/kyleve/Listable/compare/0.19.0...0.20.0
[0.19.0]: https://github.com/kyleve/Listable/compare/0.18.0...0.19.0
[0.18.0]: https://github.com/kyleve/Listable/compare/0.17.0...0.18.0
[0.17.0]: https://github.com/kyleve/Listable/compare/0.16.0...0.17.0
[0.16.0]: https://github.com/kyleve/Listable/compare/0.15.1...0.16.0
[0.15.1]: https://github.com/kyleve/Listable/compare/0.15.0...0.15.1
[0.15.0]: https://github.com/kyleve/Listable/compare/0.14.2...0.15.0
[0.14.1]: https://github.com/kyleve/Listable/compare/0.14.1...0.14.2
[0.14.1]: https://github.com/kyleve/Listable/compare/0.13.0...0.14.1
[0.13.0]: https://github.com/kyleve/Listable/compare/0.12.1...0.13.0
[0.12.1]: https://github.com/kyleve/Listable/compare/0.12.0...0.12.1
[0.12.0]: https://github.com/kyleve/Listable/compare/0.11.0...0.12.0
[0.11.0]: https://github.com/kyleve/Listable/compare/0.10.1...0.11.0
[0.10.1]: https://github.com/kyleve/Listable/compare/0.10.0...0.10.1
[0.10.0]: https://github.com/kyleve/Listable/compare/0.9.0...0.10.0
