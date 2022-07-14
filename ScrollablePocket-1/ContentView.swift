//
//  ContentView.swift
//  ScrollablePocket-1
//
//  Created by Olha Pavliuk on 07.07.2022.
//

import SwiftUI
import Combine
import scrollable_pocket

struct ContentView: View {
    @ObservedObject private var viewModel = ScrollablePocketViewModel<MySmallView>(smallViews: smallViewsSample())
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                ScrollablePocket<MySmallView, MyPlaceholder>(
                    viewModel: viewModel,
                    rowHeight: 40,
                    pocketWidth: Constant.pocketWidth,
                    placeholderBuilder: { view in
                        return MyPlaceholder()
                    }
                )
                .offset(x: -reader.size.width/2 + Constant.pocketWidth/2, y: 0) // -reader.size.height/2
                .frame(width: Constant.pocketWidth, height: 700)
                    .padding()
            
                Rectangle().fill(.blue)
                    .frame(width: viewModel.drag?.viewRectInPocket.width ?? 0, height: viewModel.drag?.viewRectInPocket.height ?? 0)
                    .offset(x: -reader.size.width/2 + (viewModel.drag?.touchLocationInPocket.x ?? 0) , y: -350 + (viewModel.drag?.touchLocationInPocket.y ?? 0))
                
                //if let drag = viewModel.drag {
                MySmallView(str: viewModel.draggedViewId)
                    .font(.largeTitle)
                    .opacity(1)
                    //.opacity(viewModel.text.isEmpty ? 0 : 1)
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

private struct MySmallView: View, Identifiable, Hashable, SizePrefferrable {
    var viewId: String {
        return str
    }
    
    var id = UUID()
    
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
    func preferredSize(rowHeight: CGFloat) -> Int {
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

private enum Constant {
    static let pocketWidth: CGFloat = 500
}
