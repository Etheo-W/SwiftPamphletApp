//
//  SwiftPamphletAppApp.swift
//  SwiftPamphletApp
//
//  Created by Ming Dai on 2021/11/17.
//

import SwiftUI
import Combine

@main
struct SwiftPamphletAppApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            SwiftPamphletApp()
//            Demo()
        }
    }
}

struct Demo: View {
    var body: some View {
        Group {
            AnimateLayout()
        }
        .frame(minWidth:300, minHeight: 550)
        .onAppear {
            
        }
    }
}


struct SwiftPamphletApp: View {
    @StateObject var appVM = AppVM()
    @State var sb = Set<AnyCancellable>()
    @State var alertMsg = ""
    @State var stepCount = 0
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    var body: some View {
        NavigationView {
            if SPConfig.gitHubAccessToken.isEmpty == true {
                VStack {
                    Text("Ops!")
                    Text("Token 未设置")
                }
                VStack {
                    Text("请在 SwiftPamphletAppConfig.swift 的 gitHubAccessToken 加入你的 GitHub Access Token").font(.title)
                    HStack {
                        Text("在 GitHub")
                        ButtonGoGitHubWeb(url: "settings/tokens", text: "点这里", ignoreHost: true)
                        Text("进行申请")
                    }
                }
            } else {
                SPSidebar()
                    .onAppear(perform: {
                        appVM.nsck()
                        appVM.doing(.loadDBRepoInfo) // 读取数据存储仓库数据
                    })
                    .onReceive(timer, perform: { time in
                        print(time)
                        if appVM.reposNotis.count > 0 {
                            if stepCount >= appVM.reposNotis.count {
                                stepCount = 0
                            }
                            var arr = [String]()
                            for (k,_) in appVM.reposNotis {
                                arr.append(k)
                            }
                            let repoName = arr[stepCount]
                            
                            let vm = RepoVM(repoName: repoName)
                            vm.doing(.notiRepo)
                            appVM.doing(.loadDBRepoInfo)
                            appVM.calculateReposCountNotis()
                            stepCount += 1
                            print(stepCount)
                        }
                        
                    })
                SPIssuesListView(vm: RepoVM(repoName: SPConfig.pamphletIssueRepoName))
                IntroView()
                NavView()
            }
        }
        .frame(minHeight: 700)
        .navigationTitle("戴铭的 Swift 小册子 \(appVM.alertMsg)")
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.navigation) {
                Button {
                    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                } label: {
                    Label("Sidebar", systemImage: "sidebar.left")
                }
            }
        }
        .environmentObject(appVM)
        
    }
}

struct IntroView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            Text("戴铭的 Swift 小册子").bold().font(.largeTitle)
            Text("一本活的 Swift 手册")
            Text("版本1.0").font(.footnote)
        }
        .frame(minWidth: SPConfig.detailMinWidth)
    }
}

struct NavView: View {
    var body: some View {
        VStack {
            IssueView(vm: IssueVM(repoName: SPConfig.pamphletIssueRepoName, issueNumber: 1), type: .hiddenUserInfo)
        }
        .frame(minWidth: SPConfig.detailMinWidth)
    }
}

struct SPSidebar: View {
    @EnvironmentObject var appVM: AppVM
    var body: some View {
        List {
            Section("GitHub 上相关动态") {
                
                NavigationLink(destination: ActiveDeveloperListView(vm: IssueVM(repoName: SPConfig.pamphletIssueRepoName, issueNumber: 30))) {
                    Label("开发者动态", systemImage: "person.2.wave.2")
                }
                
                NavigationLink(destination: GoodReposListView(vm: IssueVM(repoName: SPConfig.pamphletIssueRepoName, issueNumber: 31))) {
                    if appVM.reposCountNotis > 0 {
                        Label("仓库动态", systemImage: "book.closed")
                            .badge(appVM.reposCountNotis)
                    } else {
                        Label("仓库动态", systemImage: "book.closed")
                    }
                }

            }
            Section("Swift指南") {
                
                NavigationLink(destination: IssuesListFromCustomView(vm: IssueVM(repoName: SPConfig.pamphletIssueRepoName, issueNumber: 19))) {
                    Label("语法速查", systemImage: "function")
                }
                
                NavigationLink(destination: IssuesListFromCustomView(vm: IssueVM(repoName: SPConfig.pamphletIssueRepoName, issueNumber: 20))) {
                    Label("特性", systemImage: "pencil")
                }
                
                NavigationLink(destination: IssuesListFromCustomView(vm: IssueVM(repoName: SPConfig.pamphletIssueRepoName, issueNumber: 21))) {
                    Label("专题", systemImage: "graduationcap")
                }
            }
            Section("库使用指南") {
                
                NavigationLink(destination: IssuesListFromCustomView(vm: IssueVM(repoName: SPConfig.pamphletIssueRepoName, issueNumber: 60))) {
                    Label("Combine", systemImage: "app.connected.to.app.below.fill")
                }
                
                NavigationLink(destination: IssuesListFromCustomView(vm: IssueVM(repoName: SPConfig.pamphletIssueRepoName, issueNumber: 62))) {
                    Label("Concurrency", systemImage: "timer")
                }
                
                NavigationLink(destination: IssuesListFromCustomView(vm: IssueVM(repoName: SPConfig.pamphletIssueRepoName, issueNumber: 61))) {
                    Label("SwiftUI", systemImage: "rectangle.fill.on.rectangle.fill")
                }
            }
            
            Section("小册子") {
                NavigationLink(destination: SPIssuesListView(vm: RepoVM(repoName: SPConfig.pamphletIssueRepoName))) {
                    Label("小册子议题", systemImage: "square.3.layers.3d.down.right")
                }
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 160)
        .toolbar {
            ToolbarItem {
                Menu {
                    Text("Ops！发现这里了")
                    Text("彩蛋下个版本见")
                    Text("隐藏彩蛋1")
                    Text("隐藏彩蛋2")
                } label: {
                    Label("Label", systemImage: "slider.horizontal.3")
                }
            }
        }
    }
}

protocol Jsonable : Identifiable, Decodable, Hashable {}

// MARK: Evironment Model


class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var op: String?
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("-- AppDelegate Section --")
        
        
        
        
        
        
        
//        self.window.makeKey()
    }
}





