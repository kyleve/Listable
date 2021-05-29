//
//  CollectionViewDictionaryDemoViewController.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/25/19.
//

import UIKit
import ListableUI
import BlueprintUILists
import BlueprintUI
import BlueprintUICommonControls
import EnglishDictionary


final public class CollectionViewDictionaryDemoViewController : UIViewController
{
    let listView = ListView()
    
    override public func loadView()
    {
        self.title = "Dictionary"
        
        self.listView.layout = .table {
            $0.layout.set {
                $0.padding = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 20.0, right: 20.0)
                $0.width = .atMost(600.0)
                $0.sectionHeaderBottomSpacing = 10.0
                $0.itemSpacing = 7.0
                $0.interSectionSpacingWithNoFooter = 10.0
            }
        }
        
        self.listView.behavior.keyboardDismissMode = .interactive
        
        self.listView.set(source: Source(dictionary: EnglishDictionary.dictionary), initial: Source.SearchState())
        
        self.view = self.listView
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Scroll Down", style: .plain, target: self, action: #selector(tappedScrollDown)),
            UIBarButtonItem(title: "Scroll Up", style: .plain, target: self, action: #selector(tappedScrollUp)),
        ]
    }
    
    @objc func tappedScrollDown()
    {
        self.listView.scrollTo(
            item: Identifier<WordRow>("clam"),
            position: .init(position: .centered, ifAlreadyVisible: .doNothing),
            animation: .default
        )
    }
    
    @objc func tappedScrollUp()
    {
        self.listView.scrollTo(
            item: Identifier<WordRow>("aard-vark"),
            position: .init(position: .centered, ifAlreadyVisible: .doNothing),
            animation: .default
        )
    }

    struct Source : ListViewSource
    {
        let dictionary : EnglishDictionary
        
        struct SearchState : Equatable
        {
            var filter : String = ""
                        
            func include(_ word : String) -> Bool
            {
                guard self.filter.isEmpty == false else {
                    return true
                }
                
                return word.contains(self.filter.lowercased())
            }
        }

        func content(with state: SourceState<SearchState>, content: inout Content)
        {
            // Add the search bar section.
            
            content += Section("search") { rows in
                // When the search bar's text changes, update the filter.
                let search = SearchBarElement(text: state.value.filter) { string in
                    state.value.filter = string
                }
                
                rows += Item(
                    search,
                    layouts: .init {
                        $0.table.width = .fill
                    }
                )
            }
            
            var hasContent = false
            
            // Add a section for each letter in the dictionary.
            
            content += self.dictionary.wordsByLetter.map { letter in
                return Section(letter.letter) { section in
                    
                    // Set the header.
                    section.header = HeaderFooter(SectionHeader(title: letter.letter))
                    
                    // Only include word rows that pass the filter.
                    section += letter.words.compactMap { word in
                        guard state.value.include(word.word) else {
                            return nil
                        }
                        
                        hasContent = true
                        
                        return Item(
                            WordRow(title: word.word, detail: word.description),
                            sizing: .thatFits(.init(.atMost(250.0)))
                        )
                    }
                }
            }
            
            // Remove filtered sections.
            content.removeEmpty()
            
            // If there's no content, show an empty state.
            if hasContent == false {
                content += Section("empty") { section in
                    section += WordRow(
                        title: "No Results For '\(state.value.filter)'",
                        detail: "Please enter a different search."
                    )
                }
            }
        }
    }
}

fileprivate struct SearchBarElement : ItemContent
{
    var text : String
    
    var onChange : (String) -> ()
    
    // MARK: ItemElement
        
    var identifier: Identifier<SearchBarElement> {
        return .init("search")
    }
    
    func apply(
        to views : ItemContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyItemContentInfo,
        send : @escaping Coordinator.SendAction
    ) {
        views.content.onStateChanged = self.onChange
        views.content.text = self.text
    }
    
    func isEquivalent(to other: SearchBarElement) -> Bool {
        return self.text == other.text
    }
    
    typealias ContentView = SearchBar
    
    static func createReusableContentView(frame: CGRect) -> ContentView
    {
        return SearchBar(frame: frame)
    }
    
    func apply(to views : ItemContentViews<Self>, with info: ApplyItemContentInfo) {}
}

fileprivate struct SectionHeader : BlueprintHeaderFooterContent, Equatable
{
    var title : String
    
    // MARK: BlueprintItemElement
    
    var elementRepresentation: Element {
        return Box(
            backgroundColor: UIColor(white: 0.85, alpha: 1.0),
            cornerStyle: .rounded(radius: 10.0),
            wrapping: Inset(
                top: 10.0,
                bottom: 10.0,
                left: 20.0,
                right: 20.0,
                wrapping: Label(text: self.title) {
                    $0.font = .systemFont(ofSize: 32.0, weight: .bold)
            })
        )
    }
    
    var identifier: Identifier<SectionHeader> {
        return .init(self.title)
    }
}


fileprivate struct WordRow : BlueprintItemContent, Equatable
{
    var title : String
    var detail : String
    
    // MARK: BlueprintItemElement
    
    func element(
        with info: ApplyItemContentInfo,
        send : @escaping Coordinator.SendAction
    ) -> Element
    {
        return Box(
            backgroundColor: .init(white: 0.96, alpha: 1.0),
            cornerStyle: .rounded(radius: 10.0),
            wrapping: Inset(top: 10.0, bottom: 10.0, left: 20.0, right: 20.0, wrapping: Column { column in
                column.add(child: Label(text: self.title) {
                    $0.font = .systemFont(ofSize: 18.0, weight: .semibold)
                })
                
                column.add(child: Spacer(size: .init(width: 0.0, height: 10.0)))
                
                column.add(child: Label(text: self.detail) {
                    $0.font = .italicSystemFont(ofSize: 14.0)
                    $0.color = .darkGray
                })
            })
        )
    }
    
    var identifier: Identifier<WordRow> {
        return .init(self.title)
    }
}


fileprivate final class SearchBar : UISearchBar, UISearchBarDelegate
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    typealias StateChanged = (String) -> ()
    var onStateChanged : StateChanged?
    
    var searchTimer : Timer?
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.searchTimer?.invalidate()
        
        self.searchTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
            self.onStateChanged?(searchText)
        }
    }
}
