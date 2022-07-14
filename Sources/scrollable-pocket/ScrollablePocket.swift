//
//  ScrollablePocket.swift
//  ScrollablePocket-1
//
//  Created by Olha Pavliuk on 08.07.2022.
//

import SwiftUI
import Combine

public struct ScrollablePocket<SmallContentView: View & Identifiable & Hashable & SizePrefferrable, PlaceholderView: View>: View {
    @ObservedObject var viewModel: ScrollablePocketViewModel<SmallContentView>
    @State private var scrollOffset: CGPoint = .zero
    private let rowHeight: CGFloat
    private let pocketWidth: CGFloat
    private var placeholderBuilder: (SmallContentView) -> PlaceholderView
    
    @State private var smallViewsLayout = [[SmallContentView]]()
    @State private var smallViewsFrames = [[CGRect]]()
    
    private func updateSmallViewsLayout(_ views: [SmallContentView]) {
        let layout = makeLayout(views)
        smallViewsLayout = layout.0
        smallViewsFrames = layout.1
    }
    
    public init(viewModel: ScrollablePocketViewModel<SmallContentView>,
         rowHeight: CGFloat, pocketWidth: CGFloat,
         placeholderBuilder: @escaping (SmallContentView) -> PlaceholderView) {
        self.viewModel = viewModel
        self.rowHeight = rowHeight
        self.pocketWidth = pocketWidth
        self.placeholderBuilder = placeholderBuilder
        updateSmallViewsLayout(viewModel.smallViews)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical,  showsIndicators: true) {
                VStack(spacing: 0) {
                    ForEach(0..<smallViewsLayout.count, id: \.self) { smallViewsIdx1 in
                        HStack(spacing: 0) {
                            ForEach(0..<smallViewsLayout[smallViewsIdx1].count, id: \.self) { smallViewsIdx2 in
                                let smallView = smallViewsLayout[smallViewsIdx1][smallViewsIdx2]
                                let frame = smallViewsFrames[smallViewsIdx1][smallViewsIdx2]
                                //GeometryReader { geometry2 in
                                    ZStack {
                                        smallView
                                            //.offset(y: frame.minY)
                                            .frame(height: frame.height)
                                            .background(.green)
                                            .cornerRadius(10)
                                            .onTapGesture {  }
                                            .gesture( smallViewDragGesture(view: smallView, someFrame: frame) )
                
                                        placeholderForView(smallView)
                                            //.offset(y: frame.minY)
                                            .frame(height: frame.height)
                                            .background(.green)
                                    }
                                //}
                                
                            }
                        }
                    }
                    .onReceive(viewModel.$smallViews, perform: { views in
                        updateSmallViewsLayout(views)
                    })
                }
                .coordinateSpace(name: "hstack-shmack")
                .readingScrollView(from: "pocket-scroll", into: $scrollOffset)
                .background(Color.yellow)
            }
            .coordinateSpace(name: "pocket-scroll")
        }
    }
    
    private func makeLayout(_ views: [SmallContentView]) -> ([[SmallContentView]], [[CGRect]]) {
        var result = [[SmallContentView]]()
        var frames = [[CGRect]]()
        var baselineY: CGFloat = 0
        result.append([views[0], views[1]])
        frames.append([CGRect(x: 0, y: 0, width: pocketWidth/2, height: rowHeight), CGRect(x: 0, y: 0, width: pocketWidth/2, height: rowHeight)])
        baselineY += 30
        for idx in 2..<views.count {
            let curHeight = rowHeight*CGFloat(views[idx].preferredSize(rowHeight: rowHeight))
            result.append([views[idx]])
            
            frames.append([CGRect(x: 0, y: baselineY, width: pocketWidth, height: curHeight)])
            baselineY += curHeight
        }
        return (result, frames)
    }
    
    @ViewBuilder
    private func placeholderForView(_ view: SmallContentView) -> some View {
        if viewModel.draggedViewId == view.viewId && viewModel.drag?.type == .change {
            placeholderBuilder(view)
        } else {
            EmptyView()
        }
    }
    
    // "someFrame" is absolute; to make it relative, substract scroll offset!
    private func smallViewDragGesture(view: SmallContentView, someFrame: CGRect) -> some Gesture {
        return DragGesture(minimumDistance: 0, coordinateSpace: .named("hstack-shmack"))
            .onChanged({
                let touchLocationInPocket = CGPoint(x: $0.location.x - scrollOffset.x, y: $0.location.y - scrollOffset.y)
                let viewRectInPocket = someFrame.offsetBy(dx: -scrollOffset.x, dy: -scrollOffset.y)
                print("TADAM: touchLocationInPocket = \(touchLocationInPocket), viewRectInPocket = \(viewRectInPocket), scrollOffset = \(scrollOffset)")
                viewModel.draggedViewId = view.viewId
                viewModel.drag =
                    SmallViewDragInfo(
                        type: .change,
                        touchLocationInPocket: touchLocationInPocket,
                        viewRectInPocket: viewRectInPocket)
            })
            .onEnded { _ in
                viewModel.drag = nil
                viewModel.draggedViewId = ""
//                    SmallViewDragInfo(
//                        type: .end,
//                        touchLocationInPocket: .zero,
//                        viewLocationInPocket: .zero,
//                        view: view)
            }
    }
}

public protocol SizePrefferrable {
    func preferredSize(rowHeight: CGFloat) -> Int
    var viewId: String { get }
}

public struct SmallViewDragInfo<SmallContentView: View> {
    public enum DragType {
        case change, end
    }
    
    public let type: DragType
    
    /// In In the visible part  of the  pocket
    public let touchLocationInPocket: CGPoint
    
    /// In the visible part  of the  pocket, not in the entire scroll view
    public let viewRectInPocket: CGRect
}

public class ScrollablePocketViewModel<SmallContentView: View & Hashable & SizePrefferrable>: ObservableObject {
    @Published public var smallViews: [SmallContentView]
    @Published public var drag: SmallViewDragInfo<SmallContentView>?
    @Published public var draggedViewId: String = ""
    
    public init(smallViews: [SmallContentView]) {
        self.smallViews = smallViews
    }
}

