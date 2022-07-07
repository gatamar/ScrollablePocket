I need a SwiftUI module with a following properties:

1. It's a `View`, parametrized by `SmallContentView`.
2. It's initialized with some kind of Publisher which emits an array of `SmallContentView`.
3. `SmallContentView` has a function of calculating the `height`; an array is placed in a vertical stack; in each row of the stack there can be either 1 or few `SmallContentView`s with the same height (a height of each row), and the same uniform width.
4. This view is scrollable.  
5. Besides of scrolling, each of `SmallContentView`s can be dragged out of the `View`. When the dragging starts, the `View` emits the dragged view, the coordinate of drag inside the `View`, the coordinate of drag inside the dragged view. A placeholder is shown in place of  the dragged view. When the drag ends, depending of the end drag location, the `SmallContentView` is either returned to the `View` or removed from it with recalculating the layout.

Distribution requirements:
1. It's a SwiftUI framework
2. It's distributed via SPM


ScrollablePocket     
