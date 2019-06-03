//
//  OnboardingViewController.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 5/28/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import UIKit

class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate{

    var pageControl = UIPageControl()
    
   var pageIndex = 0
    
    public var pageDescriptions: Array<String> =  [
        "We believe the daily application of sunscreen is the most important thing you can do to protect your skin",
        "Protecting our skin from the sun is a daily habit that’s easy to overlook"]
    
    public var imageNames: Array<String> = ["sun-rays","hand-with-sunscreen2"]
    
    
    fileprivate lazy var pages: [UIViewController] = {
        return [
            self.getViewController(0),
            self.getViewController(1)
        ]
    }()
    
    fileprivate func getViewController(_ index: Int) -> UIViewController
    {
        let pageContentViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PageContentViewController") as! OnboardingPageContent
        pageContentViewController.descriptionText = self.pageDescriptions[index]
        pageContentViewController.pageIndex = index
        pageContentViewController.imageName = self.imageNames[index]
        
        pageContentViewController.delegate = self
        
        return pageContentViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate   = self
        //configurePageControl()
        view.backgroundColor = UIColor.white
        
        
        let appearance = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
        appearance.pageIndicatorTintColor = UIColor.lightGray
        appearance.currentPageIndicatorTintColor = UIColor.orange
        
        
        if let firstVC = pages.first
        {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }

    }
    
    func configurePageControl() {
        
       // pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 60,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = pages.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.lightGray
        self.pageControl.pageIndicatorTintColor = UIColor.orange
        self.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        self.view.addSubview(pageControl)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = pages.index(of: viewController) else
        {
            return nil
            
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else
        {
            return pages.last
                
        }
        
        guard pages.count > previousIndex else
        {
                return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {

        guard let viewControllerIndex = pages.index(of: viewController)
            else
        {
                return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else
        {
            return pages.first
            
        }
        
        guard pages.count > nextIndex
            else
        {
            return nil
        }
        
        return pages[nextIndex]
    }
    
    
    
    // Enables pagination dots
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 2
    }
    
    // This only gets called once, when setViewControllers is called
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
 
    
    // MARK: Delegate functions
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = pages.index(of: pageContentViewController)!
    }
    
}

extension OnboardingViewController: OnboardingPageContentDelegate {
    func didTapNext(index: Int) {
        if pages.count == (index + 1){
            //dismiss view controller
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
            return
        }
        self.setViewControllers([self.getViewController(index+1)], direction: .forward, animated: true, completion: nil)
      
        
    }
}


