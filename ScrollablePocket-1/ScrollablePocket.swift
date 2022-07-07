//
//  ScrollablePocket.swift
//  ScrollablePocket-1
//
//  Created by Olha Pavliuk on 08.07.2022.
//

import SwiftUI
import Combine

struct ScrollablePocket<SmallContentView: View & Identifiable & Hashable & SizePrefferrable, PlaceholderView: View>: View {
    @ObservedObject var viewModel: ScrollablePocketViewModel<SmallContentView>
    @State private var scrollOffset: CGPoint = .zero
    private var oneHeight: CGFloat
    private var placeholderBuilder: (SmallContentView) -> PlaceholderView
    
    @State private var smallViewsLayout = [[SmallContentView]]()
    @State private var smallViewsFrames = [[CGRect]]()
    
    private func updateSmallViewsLayout(_ views: [SmallContentView]) {
        let layout = makeLayout(views)
        smallViewsLayout = layout.0
        smallViewsFrames = layout.1
    }
    
    init(viewModel: ScrollablePocketViewModel<SmallContentView>,
         oneHeight: CGFloat,
         placeholderBuilder: @escaping (SmallContentView) -> PlaceholderView) {
        self.viewModel = viewModel
        self.oneHeight = oneHeight
        self.placeholderBuilder = placeholderBuilder
        updateSmallViewsLayout(viewModel.smallViews) // TODO: also on change
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical,  showsIndicators: true) {
                VStack(spacing: 0) {
                    ForEach(0..<smallViewsLayout.count, id: \.self) { smallViewsIdx1 in
                        HStack(spacing: 0) {
                            ForEach(0..<smallViewsLayout[smallViewsIdx1].count, id: \.self) { smallViewsIdx2 in
                                let smallView = smallViewsLayout[smallViewsIdx1][smallViewsIdx2]
                                let frame = smallViewsFrames[smallViewsIdx1][smallViewsIdx2]
                                ZStack {
                                    smallView
                                        .frame(height: frame.height)
                                        .background(.green)
                                        .cornerRadius(10)
                                        .onTapGesture {  }
                                        .gesture( smallViewDragGesture(view: smallView) )
            
                                    placeholderForView(smallView)
                                        .frame(height: frame.height)
                                        .background(.green)
                                }
                            }
                        }
                    }
                    .onReceive(viewModel.$smallViews, perform: { views in
                        updateSmallViewsLayout(views)
                    })
                }
            }
            .coordinateSpace(name: "hstack-shmack")
            .readingScrollView(from: "pocket-scroll", into: $scrollOffset)
            .background(Color.yellow)
        }
    }
    
    private func makeLayout(_ views: [SmallContentView]) -> ([[SmallContentView]], [[CGRect]]) {
        var result = [[SmallContentView]]()
        var frames = [[CGRect]]()
        var baselineY: CGFloat = 0
        result.append([views[0], views[1]])
        frames.append([CGRect(x: 0, y: 0, width: 100, height: 30), CGRect(x: 0, y: 0, width: 100, height: 30)])
        baselineY += 30
        for idx in 2..<views.count {
            let curHeight = oneHeight*CGFloat(views[idx].preferredSize(oneHeight: oneHeight))
            result.append([views[idx]])
            
            frames.append([CGRect(x: 0, y: baselineY, width: 0, height: curHeight)])
            baselineY += curHeight
        }
        return (result, frames)
    }
    
    @ViewBuilder
    private func placeholderForView(_ view: SmallContentView) -> some View {
        if viewModel.drag?.text == view.text && viewModel.drag?.type == .change {
            placeholderBuilder(view)
        } else {
            EmptyView()
        }
    }
    
    private func smallViewDragGesture(view: SmallContentView) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("hstack-shmack"))
            .onChanged({
                let locationInPocket = CGPoint(x: $0.location.x - scrollOffset.x, y: $0.location.y - scrollOffset.y)
                print("TADAM: locationInPocket = \(locationInPocket)")
                viewModel.drag =
                    SmallViewDragInfo(
                        type: .change,
                        touchLocationInPocket: locationInPocket,
                        viewLocationInPocket: .zero,
                        text: view.text)
            })
            .onEnded { _ in
                viewModel.drag = nil
//                    SmallViewDragInfo(
//                        type: .end,
//                        touchLocationInPocket: .zero,
//                        viewLocationInPocket: .zero,
//                        view: view)
            }
    }
}

protocol SizePrefferrable {
    func preferredSize(oneHeight: CGFloat) -> Int
    var text: String { get }
}

struct SmallViewDragInfo<SmallContentView: View> {
    enum DragType {
        case change, end
    }
    
    let type: DragType
    let touchLocationInPocket: CGPoint
    let viewLocationInPocket: CGPoint
    let text: String
}

class ScrollablePocketViewModel<SmallContentView: View & Hashable & SizePrefferrable>: ObservableObject {
    @Published var smallViews: [SmallContentView]
    @Published var drag: SmallViewDragInfo<SmallContentView>?
    
    init(smallViews: [SmallContentView]) {
        self.smallViews = smallViews
        print("TADAM: re-render viewmodel")
    }
}

