//
//  ViewController.swift
//  roto
//
//  Created by Vuk Knezevic on 03/09/19.
//  Copyright © 2019 Vuk Knezevic. All rights reserved.
//

import UIKit
import SnapKit

enum Direction {
    case Up
    case Down
}

enum Section {
    case Top
    case Bottom
}

class ViewController: UIViewController {
    
    var iv: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var iv2: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var iv3: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var iv4: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var iv5: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var iv6: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var topView: UIImageView = {
        let v = UIImageView()
        v.backgroundColor = .clear
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var bottomView: UIImageView = {
        let v = UIImageView()
        v.backgroundColor = .clear
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var imageViews: [UIImageView]?

    override func viewDidLoad() {
        super.viewDidLoad()

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.view.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tap)
        
        imageViews = [bottomView, iv, iv2, iv3, iv4, iv5, iv6, topView]
        
        // poslozicu sve imageView-eve jedan iza drugog
        for i in 0..<imageViews!.count {
            i == 0 ? self.view.addSubview(imageViews![i]) :  self.view.insertSubview(imageViews![i], belowSubview: imageViews![i - 1])
        }
        
        setContraints()
        self.view.backgroundColor = .yellow
        
    }
    
    let transformLayer = CATransformLayer()
    var imageCounter = 2
    var viewCounter = 1
    var initailSection: Section?
    var startPoint = CGPoint.zero
    var inRotation = false

    func setContraints() {
        imageViews!.forEach {
            $0.snp.remakeConstraints({ (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(self.view.bounds.height / 2)
            })
        }
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // slike prate oznake iz assetsa, a namerno propustam prvi i poslednji imageView iz niza jer su oni tu samo zbog korektne rotacije
        for i in 1...imageViews!.count - 2 {
            imageViews?[i].image = UIImage(named: "s\(2*i)")
            imageViews?[i].contentMode = .scaleToFill
        }
        
        var perspective = CATransform3DIdentity
        perspective.m34 = 0.5 / 1000
        transformLayer.transform = perspective
        
        // vezujem transformirajuci layer za odgovarajucu poziciju na ekranu
        transformLayer.position = CGPoint(x: 0, y: view.bounds.midY - view.bounds.midY/2)
        // dodajem mu prvi layer za rotaciju koji nece vise biti dostupan za rotiranje jer je potreban samo zbog korektne rotacije ostalih
        transformLayer.addSublayer(imageViews![0].layer)
        // vezujem tacku rotacije za sredinu donje ivice image view-a
        imageViews![0].layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        // zbog pojavljivanja layera koji je sledeci u nizu, upravo njemu dajem da nosi rotaciju transformLayera
        imageViews![viewCounter].layer.addSublayer(transformLayer)
        // prva je nevidljiva rotacija, obavljam je zbog slaganja view-a tj zbog korektne rotacije ostalih imageView-eva
        UIView.animate(withDuration: 0.1, animations: {
            self.imageViews![0].layer.transform = CATransform3DMakeRotation(.pi, 1, 0, 0)
        }) { (finished) in
            // oslobadjam transform layer
            self.transformLayer.removeFromSuperlayer()
            // oslobadjam imageView koji sam rotirao
            self.imageViews![0].layer.removeFromSuperlayer()
            // on je u ovo trenutku nil pa ga opet instanciram
            self.imageViews![0] = UIImageView()
            self.imageViews![0].backgroundColor = .clear
            // menjam mu poziciju na ekranu
            self.view.addSubview(self.imageViews![0])
            self.imageViews![0].snp.remakeConstraints({ (make) in
                make.bottom.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(self.view.bounds.height / 2)
            })
        }
    }
    
    @objc func handleTap(sender: UIPanGestureRecognizer) {
        let startPoint = sender.location(in: self.view)
        let screenSection = self.screenSection(startPoint: startPoint)
        transformLayer.position = CGPoint(x: 0, y: view.bounds.midY - view.bounds.midY/2)
        if !inRotation {
            if viewCounter >= 1 && viewCounter < imageViews!.count - 1 && screenSection == .Top {
                //dodajem layer imageView-a transformisucem layeru
                transformLayer.addSublayer(imageViews![viewCounter].layer)
                // vezujem tacku rotacije za sredinu donje ivice image view-a
                imageViews![viewCounter].layer.anchorPoint = CGPoint(x: 0.5, y: 1)
                // zbog pojavljivanja layera koji je sledeci u nizu, upravo njemu dajem da nosi rotaciju transformLayera
                imageViews![viewCounter + 1].layer.addSublayer(transformLayer)
                inRotation = true
                
                UIView.animate(withDuration: 1, animations: {
                    self.imageViews![self.viewCounter].layer.transform = CATransform3DMakeRotation(.pi/2 * 0.95, 1, 0, 0)
                }) { (finished) in
                    if self.viewCounter > 1 && self.viewCounter < self.imageViews!.count - 1{
                        self.view.layer.insertSublayer(self.imageViews![self.viewCounter + 1].layer, above: self.imageViews![self.viewCounter - 1].layer)
                    }
                    if self.viewCounter == self.imageViews!.count - 1{
                        self.view.layer.insertSublayer(self.topView.layer, above: self.imageViews![self.viewCounter - 1].layer)
                    }
                    let image = UIImage(cgImage: UIImage(named: "s\(self.imageCounter + 1)")!.cgImage!, scale: 1.0, orientation: .downMirrored)
                    self.imageViews![self.viewCounter].image = image
                    UIView.animate(withDuration: 1, animations: {
                        self.imageViews![self.viewCounter].layer.transform = CATransform3DMakeRotation(.pi, 1, 0, 0)
                    }) { (finished) in
                        
                        self.transformLayer.removeFromSuperlayer()
                        self.imageViews![self.viewCounter].layer.removeFromSuperlayer()
                        
                        self.imageViews![self.viewCounter] = UIImageView()
                        self.imageViews![self.viewCounter].image = UIImage(named: "s\(self.imageCounter + 1)")
                        self.imageViews![self.viewCounter].contentMode = .scaleToFill
                        
                        self.view.addSubview(self.imageViews![self.viewCounter])
                        self.imageViews![self.viewCounter].snp.remakeConstraints({ (make) in
                            make.bottom.equalToSuperview()
                            make.leading.equalToSuperview()
                            make.trailing.equalToSuperview()
                            make.height.equalTo(self.view.bounds.height / 2)
                        })
                        
                        if self.viewCounter < self.imageViews!.count - 1 {
                            self.initailSection = nil
                            self.viewCounter = self.viewCounter + 1
                            self.imageCounter = self.imageCounter + 2
                        }
                        self.inRotation = false
                    }
                }
                
            }
            if viewCounter > 1 && viewCounter <= imageViews!.count - 1 && screenSection == .Bottom {
                print("dole")
                self.imageViews![self.viewCounter - 1].snp.remakeConstraints({ (make) in
                    make.top.equalToSuperview()
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                    make.height.equalTo(self.view.bounds.height / 2)
                    self.imageViews![self.viewCounter - 1].frame.origin.y = 0
                })
                
                //dodajem layer imageView-a transformisucem layeru
                transformLayer.addSublayer(imageViews![viewCounter - 1].layer)
                // vezujem tacku rotacije za sredinu donje ivice image view-a
                imageViews![viewCounter - 1].layer.anchorPoint = CGPoint(x: 0.5, y: 1)
                self.imageViews![viewCounter].layer.addSublayer(transformLayer)
                
                inRotation = true
            
                self.imageViews![self.viewCounter - 1].layer.transform = CATransform3DMakeRotation(.pi, 1, 0, 0)
                let image = UIImage(cgImage: UIImage(named: "s\(self.imageCounter - 1)")!.cgImage!, scale: 1.0, orientation: .downMirrored)
                self.imageViews![self.viewCounter - 1].image = image
                
                UIView.animate(withDuration: 1, animations: {
                    self.imageViews![self.viewCounter - 1].layer.transform = CATransform3DMakeRotation(.pi/2 * 0.95, 1, 0, 0)
                }) { (finished) in
                    
                    self.imageViews![self.viewCounter - 1].image = UIImage(named: "s\(self.imageCounter - 2)")
                    
                    if self.viewCounter < self.imageViews!.count - 1 {
                        self.view.layer.insertSublayer(self.imageViews![self.viewCounter].layer, above: self.imageViews![self.viewCounter + 1].layer)
                    } else {
                        self.view.layer.insertSublayer(self.imageViews![self.viewCounter].layer, above: self.imageViews![self.imageViews!.count - 1].layer)
                    }
                    
                    
                    UIView.animate(withDuration: 1, animations: {
                        self.imageViews![self.viewCounter - 1].layer.transform = CATransform3DMakeRotation(0, 1, 0, 0)
                    }) { (finished) in
                        
                        self.transformLayer.removeFromSuperlayer()
                        self.imageViews![self.viewCounter - 1].layer.removeFromSuperlayer()
                        
                        self.imageViews![self.viewCounter - 1] = UIImageView()
                        self.imageViews![self.viewCounter - 1].image = UIImage(named: "s\(self.imageCounter - 2)")
                        self.imageViews![self.viewCounter - 1].contentMode = .scaleToFill
                        
                        self.view.addSubview(self.imageViews![self.viewCounter - 1])
                        self.imageViews![self.viewCounter - 1].snp.remakeConstraints({ (make) in
                            make.top.equalToSuperview()
                            make.leading.equalToSuperview()
                            make.trailing.equalToSuperview()
                            make.height.equalTo(self.view.bounds.height / 2)
                        })
                        
                        if self.viewCounter >= 2 {
                            self.initailSection = nil
                            self.viewCounter = self.viewCounter - 1
                            self.imageCounter = self.imageCounter - 2
                        }
                        self.inRotation = false
                    }
                }
            }
        }
        
        
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        
        if !inRotation {
            var currrentPoint = CGPoint.zero
            
            if sender.state == .began {
                
                // vezujem transformirajuci layer za centar gornja polovine ekrana
                transformLayer.position = CGPoint(x: 0, y: view.bounds.midY - view.bounds.midY/2)
                
                startPoint = sender.location(in: self.view)
                
                initailSection = self.screenSection(startPoint: startPoint)
                
                if initailSection == .Top && viewCounter < imageViews!.count - 1 {
                    
                    //dodajem layer imageView-a transformisucem layeru
                    transformLayer.addSublayer(imageViews![viewCounter].layer)
                    // vezujem tacku rotacije za sredinu donje ivice image view-a
                    imageViews![viewCounter].layer.anchorPoint = CGPoint(x: 0.5, y: 1)
                    // zbog pojavljivanja layera koji je sledeci u nizu, upravo njemu dajem da nosi rotaciju transformLayera
                    imageViews![viewCounter + 1].layer.addSublayer(transformLayer)
                    
                    
                } else if  initailSection == .Bottom && viewCounter <= imageViews!.count - 1 && viewCounter > 1 {
                    
                    self.imageViews![self.viewCounter - 1].snp.remakeConstraints({ (make) in
                        make.bottom.equalTo(self.topView.snp.bottom)
                        make.leading.equalTo(self.topView.snp.leading)
                        make.trailing.equalTo(self.topView.snp.trailing)
                        make.top.equalTo(self.topView.snp.top)
                    })
                    
                    //dodajem layer imageView-a transformisucem layeru
                    transformLayer.addSublayer(imageViews![viewCounter - 1].layer)
                    // vezujem tacku rotacije za sredinu donje ivice image view-a
                    imageViews![viewCounter - 1].layer.anchorPoint = CGPoint(x: 0.5, y: 1)
                    
                    self.imageViews![viewCounter].layer.addSublayer(transformLayer)
                }
                
                
            } else if sender.state == .changed {
                
                currrentPoint = sender.location(in: self.view)
                
                let direction = self.panDirection(startPoint: startPoint, nextPoint: currrentPoint)
                let section = self.screenSection(startPoint: startPoint)
                
                if initailSection == .Top && direction == .Down && self.viewCounter < self.imageViews!.count - 1 {
                    let percentage = self.getAngle(direction: direction, section: section, startPoint: startPoint, currrentPoint: currrentPoint, imageView: self.imageViews![viewCounter])
                    if percentage >= 0 {
                        self.imageViews![viewCounter].layer.transform = CATransform3DMakeRotation((.pi / 2)  * percentage, 1, 0, 0)
                    } else {
                        self.imageViews![viewCounter].layer.transform = CATransform3DMakeRotation(.pi/2 + .pi/2  * (1 - abs(percentage)), 1, 0, 0)
                        
                        if viewCounter > 1 && viewCounter < imageViews!.count - 1{
                            self.view.layer.insertSublayer(imageViews![viewCounter + 1].layer, above: imageViews![viewCounter - 1].layer)
                        }
                        if viewCounter == imageViews!.count - 1{
                            self.view.layer.insertSublayer(topView.layer, above: imageViews![viewCounter - 1].layer)
                        }
                    }
                }
                
                if initailSection == .Bottom && direction == .Up && self.viewCounter > 1 {
                    let percentage = self.getAngle(direction: direction, section: section, startPoint: startPoint, currrentPoint: currrentPoint, imageView: self.imageViews![viewCounter - 1])
                    if percentage <= 0 {
                        self.imageViews![viewCounter - 1].layer.transform = CATransform3DMakeRotation(.pi/2 + .pi/2  * abs(percentage), 1, 0, 0)
                    } else {
                        self.imageViews![viewCounter - 1].layer.transform = CATransform3DMakeRotation((.pi / 2)  * percentage, 1, 0, 0)
                        if viewCounter < imageViews!.count - 1 {
                            self.view.layer.insertSublayer(self.imageViews![viewCounter].layer, above: imageViews![viewCounter + 1].layer)
                        } else {
                            self.view.layer.insertSublayer(self.imageViews![viewCounter].layer, above: imageViews![imageViews!.count - 1].layer)
                        }
                    }
                }
                
            } else if sender.state == .ended {
                
                currrentPoint = sender.location(in: self.view)
                
                let direction = self.panDirection(startPoint: startPoint, nextPoint: currrentPoint)
                let section = self.screenSection(startPoint: startPoint)
                
                
                if section == .Top {
                    if viewCounter < imageViews!.count - 1 {
                        let percentage = self.getAngle(direction: direction, section: section, startPoint: startPoint, currrentPoint: currrentPoint, imageView: self.imageViews![viewCounter])
                        if percentage < 0 {
                            if self.viewCounter < self.imageViews!.count - 1 {
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.imageViews![self.viewCounter].layer.transform = CATransform3DMakeRotation(.pi, 1, 0, 0)
                                }) { (finished) in
                                    
                                    self.transformLayer.removeFromSuperlayer()
                                    self.imageViews![self.viewCounter].layer.removeFromSuperlayer()
                                    
                                    self.imageViews![self.viewCounter] = UIImageView()
                                    self.imageViews![self.viewCounter].image = UIImage(named: "s\(self.imageCounter + 1)")
                                    self.imageViews![self.viewCounter].contentMode = .scaleToFill
                                    
                                    self.view.addSubview(self.imageViews![self.viewCounter])
                                    self.imageViews![self.viewCounter].snp.remakeConstraints({ (make) in
                                        make.bottom.equalToSuperview()
                                        make.leading.equalToSuperview()
                                        make.trailing.equalToSuperview()
                                        make.height.equalTo(self.view.bounds.height / 2)
                                    })
                                    
                                    if direction == .Down && self.initailSection == .Top && self.viewCounter < self.imageViews!.count - 1 {
                                        self.initailSection = nil
                                        self.viewCounter = self.viewCounter + 1
                                        self.imageCounter = self.imageCounter + 2
                                    }
                                }
                            }
                        } else {
                            UIView.animate(withDuration: 0.1, animations: {
                                self.imageViews![self.viewCounter].layer.transform = CATransform3DMakeRotation(0, 1, 0, 0)
                            }) { (finished) in
                                
                                self.transformLayer.removeFromSuperlayer()
                                self.imageViews![self.viewCounter].layer.removeFromSuperlayer()
                                
                                self.imageViews![self.viewCounter] = UIImageView()
                                self.imageViews![self.viewCounter].image = UIImage(named: "s\(self.imageCounter)")
                                self.imageViews![self.viewCounter].contentMode = .scaleToFill
                                
                                self.view.addSubview(self.imageViews![self.viewCounter])
                                self.imageViews![self.viewCounter].snp.remakeConstraints({ (make) in
                                    make.top.equalToSuperview()
                                    make.leading.equalToSuperview()
                                    make.trailing.equalToSuperview()
                                    make.height.equalTo(self.view.bounds.height / 2)
                                })
                            }
                        }
                    }
                    
                } else {
                    if self.viewCounter > 1 {
                        let percentage = self.getAngle(direction: direction, section: section, startPoint: startPoint, currrentPoint: currrentPoint, imageView: self.imageViews![viewCounter - 1])
                        if percentage < 0 {
                            UIView.animate(withDuration: 0.1, animations: {
                                self.imageViews![self.viewCounter - 1].layer.transform = CATransform3DMakeRotation(.pi, 1, 0, 0)
                            }) { (finished) in
                                
                                self.transformLayer.removeFromSuperlayer()
                                self.imageViews![self.viewCounter - 1].layer.removeFromSuperlayer()
                                
                                self.imageViews![self.viewCounter - 1] = UIImageView()
                                self.imageViews![self.viewCounter - 1].image = UIImage(named: "s\(self.imageCounter - 1)")
                                self.imageViews![self.viewCounter - 1].contentMode = .scaleToFill
                                
                                self.view.addSubview(self.imageViews![self.viewCounter - 1])
                                self.imageViews![self.viewCounter - 1].snp.remakeConstraints({ (make) in
                                    make.bottom.equalToSuperview()
                                    make.leading.equalToSuperview()
                                    make.trailing.equalToSuperview()
                                    make.height.equalTo(self.view.bounds.height / 2)
                                })
                            }
                        } else {
                            UIView.animate(withDuration: 0.1, animations: {
                                self.imageViews![self.viewCounter - 1].layer.transform = CATransform3DMakeRotation(0, 1, 0, 0)
                            }) { (finished) in
                                
                                self.transformLayer.removeFromSuperlayer()
                                self.imageViews![self.viewCounter - 1].layer.removeFromSuperlayer()
                                
                                self.imageViews![self.viewCounter - 1] = UIImageView()
                                self.imageViews![self.viewCounter - 1].image = UIImage(named: "s\(self.imageCounter - 2)")
                                self.imageViews![self.viewCounter - 1].contentMode = .scaleToFill
                                
                                self.view.addSubview(self.imageViews![self.viewCounter - 1])
                                self.imageViews![self.viewCounter - 1].snp.remakeConstraints({ (make) in
                                    make.top.equalToSuperview()
                                    make.leading.equalToSuperview()
                                    make.trailing.equalToSuperview()
                                    make.height.equalTo(self.view.bounds.height / 2)
                                })
                                
                                if direction == .Up && self.initailSection == .Bottom && self.viewCounter >= 2 {
                                    self.initailSection = nil
                                    self.viewCounter = self.viewCounter - 1
                                    self.imageCounter = self.imageCounter - 2
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        
    }
    
    func panDirection(startPoint: CGPoint?, nextPoint: CGPoint?) -> Direction? {
        guard let sPoint = startPoint, let nPoint = nextPoint else {
            return nil
        }
        return sPoint.y > nPoint.y ? .Up : .Down
    }
    
    func screenSection(startPoint: CGPoint?) -> Section? {
        let midY = self.view.bounds.height / 2
        guard let sPoint = startPoint else {
            return nil
        }
        return sPoint.y > midY ? .Bottom : .Top
    }
    
    func getAngle(direction: Direction?, section: Section?, startPoint: CGPoint, currrentPoint: CGPoint, imageView: UIImageView) -> CGFloat {
        guard let _ = direction, let _ = section else {
            return 0.0
        }
        
        let midY = self.view.bounds.height / 2
        
        let radius = midY - startPoint.y
        let projection = midY - currrentPoint.y
        let ratio = projection / abs(radius)
        
        var percentage = CGFloat()
        
        if ratio > 0 {
            percentage = 1 - ratio
        } else if ratio <= 0 {
            if projection <= radius {
                percentage = -(1 - abs(ratio))
            } else {
                percentage = ratio
            }
        }
        
        if initailSection == .Top {
            if ratio > 0 && percentage < 0.93 {
                imageView.image = UIImage(named: "s\(imageCounter)")
            } else {
                let image = UIImage(cgImage: UIImage(named: "s\(imageCounter + 1)")!.cgImage!, scale: 1.0, orientation: .downMirrored)
                imageView.image = image
            }
        } else {
            if percentage < 0.93 && percentage > 0 {
                imageView.image = UIImage(named: "s\(imageCounter - 2)")
            } else {
                let image = UIImage(cgImage: UIImage(named: "s\(imageCounter - 1)")!.cgImage!, scale: 1.0, orientation: .downMirrored)
                imageView.image = image
            }
        }
        
        return percentage
    }
    
}

