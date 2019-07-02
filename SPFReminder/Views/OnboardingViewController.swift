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
        "Choose sunscreens carefully; many have harmful ingredients that are skin irritants and coral reef killers"
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
        view.backgroundColor = UIColor.black
        
        
        /*
        let appearance = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
        appearance.pageIndicatorTintColor = UIColor.lightGray
        appearance.currentPageIndicatorTintColor = UIColor.orange
        */
        
        if let firstVC = pages.first
        {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }

    }
    
    func configurePageControl() {
        
       pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 60,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = pages.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.white
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.orange
        
        //self.nextButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.maxX - 90, y: UIScreen.main.bounds.maxY - 60, width: 100, height: 50))
        self.nextButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        self.nextButton.setTitleColor(.white, for: .normal)
        self.nextButton.setTitle("NEXT", for: .normal)
        self.nextButton.addTarget(self, action:#selector(self.didTapNext), for: .touchUpInside)
        //self.pageControl.addSubview( self.nextButton)
        
        self.doneButton = UIButton(frame: CGRect(x: 20, y: UIScreen.main.bounds.maxY - 120, width: self.view.bounds.width - 40, height: 45))
        
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 1334 {
            //iPhone 6/6S/7/8
            self.doneButton = UIButton(frame: CGRect(x: 20, y: UIScreen.main.bounds.maxY - 80, width: self.view.bounds.width - 40, height: 45))
        }
     
        self.doneButton.layer.borderColor = UIColor.white.cgColor
        self.doneButton.layer.borderWidth = 1.0
        self.doneButton.setTitle("Let's Get Started", for: .normal)
        self.doneButton.titleLabel?.textAlignment = NSTextAlignment.center
        self.doneButton.titleLabel?.font = .systemFont(ofSize: 20)
        self.doneButton.addTarget(self, action:#selector(self.didTapContinue), for: .touchUpInside)
        self.doneButton.isHidden = true
        self.view.addSubview( self.doneButton)
        
        //self.view.insetsLayoutMarginsFromSafeArea = false
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
 
    
    // MARK: Delegate functions
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = pages.index(of: pageContentViewController)!
       
        pageIndex = pages.index(of: pageContentViewController)!
        
        if pageIndex == 3 {
            self.nextButton.isHidden = true
            self.doneButton.isHidden = false
            self.pageControl.isHidden = true
            self.pageControl.isUserInteractionEnabled = false
            
        }else{
            self.nextButton.isHidden = false
            self.doneButton.isHidden = true
            self.pageControl.isHidden = false
            self.pageControl.isUserInteractionEnabled = true
        }
    }
    
    @objc func didTapContinue() {
            //dismiss view controller
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
            return
        
    }
    
    @objc func didTapNext() {
            self.setViewControllers([self.getViewController(pageIndex+1)], direction: .forward, animated: true, completion: nil)
        
    }
    
}


