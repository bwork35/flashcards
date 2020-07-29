//
//  PencilViewController.swift
//  flashcards
//
//  Created by Bryan Workman on 7/29/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import UIKit
import PencilKit

class PencilViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {
    
    //MARK: - Outlets
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var moveDrawButtonLabel: UIBarButtonItem!
    
    
    let canvasWidth: CGFloat = 768
    let canvasOverscrollHeight: CGFloat = 500
    

    var drawing = PKDrawing()
   // private weak var toolBar: UIToolbar?
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.delegate = self
        canvasView.drawing = drawing
        
        //self.navigationController?.isToolbarHidden = false
        
        canvasView.alwaysBounceVertical = true
        canvasView.allowsFingerDrawing = true
        
        if let window = parent?.view.window,
            let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            
            canvasView.becomeFirstResponder()
        }
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let canvasScale = canvasView.bounds.width / canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        
        updateContentSizeForDrawing()
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
        
        
    }
    
    
   
    
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func clearButtonTapped(_ sender: Any) {
        canvasView.drawing = PKDrawing()
    }
    @IBAction func toggleMoveOrDraw(_ sender: Any) {
        canvasView.allowsFingerDrawing.toggle()
        moveDrawButtonLabel.title = canvasView.allowsFingerDrawing ? "Move" : "Draw"
    }
    
    //MARK: - Methods

    func setupDrawing() {
        //let canvasView = PKCanvasView(frame: self.view.bounds)
        guard let window = view.window, let toolPicker = PKToolPicker.shared(for: window) else {return}
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        //view.addSubview(canvasView)
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSizeForDrawing()
    }
    
    func updateContentSizeForDrawing() {
        let drawing = canvasView.drawing
        let contentHeight: CGFloat
        
        if !drawing.bounds.isNull {
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + self.canvasOverscrollHeight) * canvasView.zoomScale)
        } else {
            contentHeight = canvasView.bounds.height
        }
        
        canvasView.contentSize = CGSize(width: canvasWidth * canvasView.zoomScale, height: contentHeight)
        
    }
  
    
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

} //End of class
