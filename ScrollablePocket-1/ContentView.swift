//
//  ContentView.swift
//  ScrollablePocket-1
//
//  Created by Olha Pavliuk on 07.07.2022.
//

import SwiftUI
import Combine

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

struct ScrollablePocket<SmallContentView: View & Hashable & SizePrefferrable, PlaceholderView: View>: View {
    @ObservedObject var viewModel: ScrollablePocketViewModel<SmallContentView>
    @State private var scrollOffset: CGPoint = .zero
    private var oneHeight: CGFloat
    private var placeholderBuilder: (SmallContentView) -> PlaceholderView
    init(viewModel: ScrollablePocketViewModel<SmallContentView>,
         oneHeight: CGFloat,
         placeholderBuilder: @escaping (SmallContentView) -> PlaceholderView) {
        self.viewModel = viewModel
        self.oneHeight = oneHeight
        self.placeholderBuilder = placeholderBuilder
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical,  showsIndicators: true) {
                ForEach(viewModel.smallViews, id: \.self) { smallView in
                    ZStack {
                        smallView
                            .frame(height: oneHeight*CGFloat(smallView.preferredSize(oneHeight: oneHeight)))
                            .background(.green)
                            .onTapGesture {  }
                            .gesture( smallViewDragGesture(view: smallView) )
                        
                        placeholderForView(smallView)
                            .frame(height: oneHeight*CGFloat(smallView.preferredSize(oneHeight: oneHeight)))
                            .background(.green)
                    }
                }
            }
            .coordinateSpace(name: "hstack-shmack")
            .readingScrollView(from: "pocket-scroll", into: $scrollOffset)
            .background(Color.yellow)
        }
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

struct ContentView: View {
    @ObservedObject private var viewModel = ScrollablePocketViewModel<MySmallView>(smallViews: smallViewsSample())
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                ScrollablePocket<MySmallView, MyPlaceholder>(
                    viewModel: viewModel,
                    oneHeight: 40,
                    placeholderBuilder: { view in
                        return MyPlaceholder()
                    }
                )
                .offset(x: -reader.size.width/2 + 250, y: 0) // -reader.size.height/2
                    .frame(width: 500, height: 700)
                    .padding()
                
                //if let drag = viewModel.drag {
                    MySmallView(str: viewModel.drag?.text ?? "none")
                        .opacity(viewModel.drag != nil ? 1 : 0)
                        .offset(x: -reader.size.width/2 + (viewModel.drag?.touchLocationInPocket.x ?? 0) , y: -350 + (viewModel.drag?.touchLocationInPocket.y ?? 0))
                //}
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: sample data

private func smallViewsSample() -> [MySmallView] {
    return (0..<100).map { MySmallView(str: String($0)) }
}

private struct MySmallView: View, Hashable, SizePrefferrable {
    @State var str: String
    
    var body: some View {
        Text(str)
            .frame(maxWidth: .infinity)
    }
    
// MARK: Hashable
    static func == (lhs: MySmallView, rhs: MySmallView) -> Bool {
        return lhs.str == rhs.str
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(str)
    }
    
// MARK: SizePrefferrable
    func preferredSize(oneHeight: CGFloat) -> Int {
        let intVal = Int(str)!
        return intVal % 3 == 0 ? 1 : 2
    }
    
    var text: String {
        return str
    }
}

private struct MyPlaceholder: View {
    var body: some View {
        Text("0")
            .background(.blue)
    }
}
