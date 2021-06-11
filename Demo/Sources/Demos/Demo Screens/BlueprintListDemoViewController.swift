//
//  BlueprintListViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 10/22/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import ListableUI
import BlueprintUILists
import BlueprintUI
import BlueprintUICommonControls


final class BlueprintListDemoViewController : UIViewController
{
    let blueprintView = BlueprintView()
    
    var showingData : Bool = true
    
    override func loadView()
    {
        self.title = "Podcasts"
        
        self.view = self.blueprintView
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Animated", style: .plain, target: self, action: #selector(toggleAnimated)),
            UIBarButtonItem(title: "No Animation", style: .plain, target: self, action: #selector(toggleNoAnimation)),
        ]
        
        self.reloadData()
    }
    
    @objc func toggleAnimated()
    {
        UIView.animate(withDuration: 1.0) {
            self.showingData.toggle()
            self.reloadData()
        }
    }
    
    @objc func toggleNoAnimation()
    {
        self.showingData.toggle()
        self.reloadData()
    }
    
    func reloadData()
    {
        self.blueprintView.element = List {
            Section("podcasts") {
                
                if showingData {
                    let podcasts = Podcast.podcasts.sorted { $0.episode < $1.episode }
                    
                    for podcast in podcasts {
                        Item(podcast, identifier: \.name) { _, _ in
                            PodcastElement(podcast: podcast)
                        } background: { _, _ in
                            Box(backgroundColor: .white, cornerStyle: .square)
                        } selectedBackground: { _, _ in
                            Box(backgroundColor: .lightGray, cornerStyle: .square)
                        }
                    }
                }
            }
        }
    }
}


fileprivate struct PodcastElement : ProxyElement {
    
    var podcast : Podcast
    
    var elementRepresentation: Element {
        Row { row in
            row.horizontalUnderflow = .growUniformly
            row.verticalAlignment = .fill

            row.add(
                growPriority: 0.0,
                shrinkPriority: 0.0,
                child: Image(image: self.podcast.image)
                    .box(corners: .rounded(radius: 8.0))
                    .constrainedTo(width: .absolute(100), height: .absolute(100))
            )

            row.add(
                growPriority: 0.0,
                child: Spacer(width: 10.0)
            )

            row.add(child: Column { column in
                column.verticalUnderflow = .growUniformly

                column.add(growPriority: 0.0, child: Label(text: self.podcast.episode) { label in
                    label.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
                    label.color = .darkGray
                })

                column.add(growPriority: 0.0, child: Spacer(size: .init(width: 0.0, height: 5.0)))

                column.add(growPriority: 0.0, child: Label(text: self.podcast.name) { label in
                    label.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
                    label.color = .gray
                })

                column.add(growPriority: 1.0, child: Spacer(size: .init(width: 0.0, height: 1.0)))

                column.add(growPriority: 0.0, child: Label(text: self.podcast.length) { label in
                    label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
                    label.color = .lightGray
                })
            })
        }
        .inset(uniform: 10.0)
    }
}


struct Podcast : Equatable
{
    var name : String
    var episode : String
    var length : String
    var image : UIImage
    
    var downloadState : DownloadState = .notDownloaded
    
    enum DownloadState : Equatable {
        case notDownloaded
        case downloading(Double)
        case downloaded
        case error
    }

    static var podcasts : [Podcast] {
        return [
            Podcast(
                name: "Nancy",
                episode: "What Do We Have In Common?",
                length: "27:54",
                image: UIImage(named: "nancy.png")!
            ),

            Podcast(
                name: "This American Life",
                episode: "409: Held Hostage",
                length: "1:01:10",
                image: UIImage(named: "this-american-life.jpg")!
            ),

            Podcast(
                name: "Wait Wait Don't Tell Me",
                episode: "Henry Winkler",
                length: "56:34",
                image: UIImage(named: "wait-wait.png")!
            ),

            Podcast(
                name: "The Impact",
                episode: "The incredible shrinking city",
                length: "56:34",
                image: UIImage(named: "the-impact.png")!
            ),

            Podcast(
                name: "Planet Money",
                episode: "935: You Asked For A Food Show",
                length: "56:34",
                image: UIImage(named: "planet-money.jpg")!
            ),

            Podcast(
                name: "Are We There Yet?",
                episode: "The Mysteries At Asteroid Bennu",
                length: "56:34",
                image: UIImage(named: "are-we-there-yet.png")!
            ),

            Podcast(
                name: "Outside Lands San Francisco",
                episode: "159: Twin Peaks Tunnel",
                length: "24:03",
                image: UIImage(named: "outside-lands.jpg")!
            ),
        ]
    }
}
