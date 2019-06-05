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
    var nextButton = UIButton()
    var doneButton = UIButton()
    
   var pageIndex = 0
    
    public var pageDescriptions: Array<String> =  [
        "We believe the daily application of sunscreen is the most important thing you can do to protect your skin",
        "Protecting your skin from the sun is a daily habit that’s easy to overlook",
        "Overexposure can lead to severe long term damage to your skin - wrinkles, sun spots, and skin cancer",
        "Select sunscreens carefully, many have harmful ingredients that are skin irritants and coral reef killers"
        ]
    
    public var imageNames: Array<String> = ["sun-rays","hand-with-sunscreen","blured-beach", "blue-ocean"]
    
    
    fileprivate lazy var pages: [UIViewController] = {
        return [
            self.getViewController(0),
            self.getViewController(1),
            self.getViewController(2),
            self.getViewController(3),
        ]
    }()
    
    fileprivate func getViewController(_ index: Int) -> UIViewController
    {
        let pageContentViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PageContentViewController") as! OnboardingPageContent
        pageContentViewController.descriptionText = self.pageDescriptions[index]
        pageContentViewController.pageIndex = index
        pageContentViewController.imageName = self.imageNames[index]
        
        return pageContentViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate   = self
        configurePageControl()
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
        
       //pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 55,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = pages.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.lightGray
        self.pageControl.pageIndicatorTintColor = UIColor.orange
        self.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
      
        
        self.nextButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.maxX - 90, y: UIScreen.main.bounds.maxY - 45, width: 100, height: 50))
         self.nextButton.setTitleColor(.darkGray, for: .normal)
         self.nextButton.setTitle("NEXT", for: .normal)
        self.view.addSubview( self.nextButton)
        
        self.doneButton = UIButton(frame: CGRect(x: 20, y: UIScreen.main.bounds.maxX - 100, width: self.view.bounds.width - 40, height: 45))
       // self.doneButton.setTitleColor(UIColor(red: 252.0/255.0, green: 180.0/255.0, blue: 22.0/255.0, alpha: 1.0) , for: .normal)
       // self.doneButton.layer.borderColor = UIColor(red: 252.0/255.0, green: 180.0/255.0, blue: 22.0/255.0, alpha: 1.0).cgColor
        self.doneButton.layer.borderColor = UIColor.white.cgColor
        self.doneButton.layer.borderWidth = 1.0
        self.doneButton.setTitle("Get Started", for: .normal)
        self.doneButton.titleLabel?.textAlignment = NSTextAlignment.center
        self.doneButton.titleLabel?.font = .systemFont(ofSize: 20)
        self.doneButton.addTarget(self, action:#selector(self.didTapContinue), for: .touchUpInside)
        self.doneButton.isHidden = true
        self.view.addSubview( self.doneButton)
        
        
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
        return 4
    }
    
    // This only gets called once, when setViewControllers is called
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
 
    
    // MARK: Delegate functions
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        //let pageContentViewController = pageViewController.viewControllers![pageIndex]
        //self.pageControl.currentPage = pages.index(of: pageContentViewController)!
        pageIndex = pageIndex + 1
        if pageIndex == 3 {
            self.nextButton.isHidden = true
            self.doneButton.isHidden = false
            self.pageControl.isUserInteractionEnabled = false
        }
    }
    
    @objc func didTapContinue() {
       
            //dismiss view controller
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
            return
        
    }
    
}


