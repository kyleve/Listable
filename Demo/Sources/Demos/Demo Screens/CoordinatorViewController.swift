//
//  CoordinatorViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 5/19/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import BlueprintUILists
import BlueprintUICommonControls


final class CoordinatorViewController : UIViewController
{
    let listView = ListView()
    
    override func loadView() {
        self.view = self.listView
        
        self.listView.configure { list in
            
            list += Section("section") { section in
                section += Podcast.podcasts.map {
                    Item(
                        PodcastElement(podcast: $0),
                        selectionStyle: .selectable(isSelected: false)
                    )
                }
            }
        }
    }
}


fileprivate struct PodcastElement : BlueprintItemContent, Equatable
{
    var podcast : Podcast
    
    var showBottomBar : Bool = false
    
    var identifier: Identifier<PodcastElement> {
        .init(podcast.name)
    }
    
    func element(
        with info: ApplyItemContentInfo,
        send : @escaping Coordinator.SendAction
    ) -> Element
    {
        Column { col in
            col.horizontalAlignment = .fill
            col.verticalUnderflow = .growUniformly
            
            let info = Row { row in
                row.horizontalUnderflow = .growUniformly
                row.verticalAlignment = .center
                row.minimumHorizontalSpacing = 10.0

                row.add(
                    growPriority: 0.0,
                    shrinkPriority: 0.0,
                    child: Image(image: self.podcast.image)
                        .box(corners: .rounded(radius: 8.0))
                        .constrainedTo(width: .absolute(75), height: .absolute(75))
                )

                row.add(child: Column { column in
                    column.verticalUnderflow = .justifyToCenter
                    column.minimumVerticalSpacing = 5.0

                    column.add(growPriority: 0.0, child: Label(text: self.podcast.episode) { label in
                        label.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
                        label.color = .darkGray
                    })

                    column.add(growPriority: 0.0, child: Label(text: self.podcast.name) { label in
                        label.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
                        label.color = .gray
                    })
                    
                    switch self.podcast.downloadState {
                    case .notDownloaded: break
                    case .downloading(let progress):
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .percent
                        
                        let progress = formatter.string(from: NSNumber(value: progress))!
                        
                        column.add(growPriority: 0.0, child: Label(text: progress) { label in
                            label.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
                            label.color = .gray
                        })
                    case .downloaded: break
                    case .error: break
                    }
                })
            }
            
            col.add(child: info)
            
            col.add(
                child: Box(backgroundColor: .darkGray).constrainedTo(height: .absolute(self.showBottomBar ? 50.0 : 0.0))
            )
        }
    }
    
    func selectedBackgroundElement(with info: ApplyItemContentInfo) -> Element? {
        Box(backgroundColor: .init(white: 0.9, alpha: 1.0))
    }
    
    func makeCoordinator(actions: CoordinatorActions, info: CoordinatorInfo) -> Coordinator
    {
        Coordinator(actions: actions, info: info)
    }
    
    final class Coordinator : ItemContentCoordinator
    {
        typealias ItemContentType = PodcastElement
        
        let actions: CoordinatorActions
        let info: CoordinatorInfo
                
        init(actions: CoordinatorActions, info: CoordinatorInfo)
        {
            self.actions = actions
            self.info = info
        }
        
        func wasSelected() {
            self.actions.update(animation: .default) {
                $0.content.showBottomBar = true
            }
            
            Timer.scheduledTimer(withTimeInterval: TimeInterval.random(in: 0.3...0.5), repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                                
                self.actions.update {
                    switch $0.content.podcast.downloadState {
                    case .notDownloaded:
                        $0.content.podcast.downloadState = .downloading(0.0)
                    case .downloading(let progress):
                        let newProgress = progress + Double.random(in: 0...0.05)
                        
                        if newProgress >= 1.0 {
                            timer.invalidate()
                            $0.content.podcast.downloadState = .downloaded
                        } else {
                            $0.content.podcast.downloadState = .downloading(newProgress)
                        }
                    case .downloaded: break
                    case .error: break
                    }
                }
            }
        }
        
        func wasDeselected() {
            self.actions.update(animation: .default) {
                $0.content.showBottomBar = false
            }
        }
    }
}
