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
    @IBOutlet weak var moveDrawButtonLabel: UIButton!
    @IBOutlet weak var ButtonView: UIView!
    
    //MARK: - Properties
    let canvasWidth: CGFloat = 768
    let canvasOverscrollHeight: CGFloat = 500
    var drawing = PKDrawing()
    var isFrontPencil: Bool?
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.delegate = self
        canvasView.drawing = drawing
        self.navigationController?.isToolbarHidden = false
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
        let title = canvasView.allowsFingerDrawing ? "Move" : "Draw"
        moveDrawButtonLabel.setTitle(title, for: .normal)
    }
    
    //MARK: - Methods
    func setupDrawing() {
        guard let window = view.window, let toolPicker = PKToolPicker.shared(for: window) else {return}
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
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
  
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        ButtonView.isHidden = true
        let topBounds = canvasView.bounds.offsetBy(dx: 0, dy: 90)
        let bottomBounds = canvasView.bounds.offsetBy(dx: 0, dy: -65)
        let setBounds = topBounds.intersection(bottomBounds)
        
        let img = UIGraphicsImageRenderer(bounds: setBounds).image { _ in
            view.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        }
        
        guard let isFrontPencil = isFrontPencil else {return}
        guard let destinationVC = segue.destination as? FlashcardDetailViewController else {return}
        if isFrontPencil {
            destinationVC.frontImg = img
        } else {
            destinationVC.backImg = img
        }
    }
} //End of class
