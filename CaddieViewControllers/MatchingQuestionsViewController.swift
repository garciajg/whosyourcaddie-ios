//
//  MatchingQuestionsViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 9/11/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit

class MatchingQuestionsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    @IBOutlet weak var questionCollectionView: UICollectionView!
    
    private var indexOfCellBeforeDragging = 0
    private var collectionViewFlowLayout: UICollectionViewFlowLayout {
        return questionCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    var questionsArray : [MatchingQuestion] = []
    var optionsLeft : [String] = []
    var pickerView = UIPickerView()
    var user = User()
    
    var score : Float = 0.0
    var newScore : Float = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        print(user.userType)
        collectionViewFlowLayout.minimumLineSpacing = 0
        
        questionCollectionView.delegate = self
        questionCollectionView.dataSource = self
        pickerView.delegate = self
        pickerView.dataSource = self
        questionArray()
        questionCollectionView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureCollectionViewLayoutItemSize()
    }
    
    func calculateSectionInset() -> CGFloat { // should be overridden
        return 0
    }
    
    private func configureCollectionViewLayoutItemSize() {
        let inset: CGFloat = calculateSectionInset()
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        collectionViewFlowLayout.itemSize = CGSize(width: collectionViewFlowLayout.collectionView!.frame.size.width - inset * 2, height: collectionViewFlowLayout.collectionView!.frame.size.height)
    }
    
    private func indexOfMajorCell() -> Int {
        let itemWidth = collectionViewFlowLayout.itemSize.width
        let proportionalOffset = collectionViewFlowLayout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let numberOfItems = questionCollectionView.numberOfItems(inSection: 0)
        let safeIndex = max(0, min(numberOfItems - 1, index))
        return safeIndex
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return questionsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "matchingcell", for: indexPath) as! MatchinCollectionViewCell
        
        let question = questionsArray[indexPath.row]
        cell.setUp(question: question)
        cell.userInput.inputView = pickerView
        cell.questionTextLabel.text = "\(indexPath.row + 11). \(question.questionText)"
        if indexPath.row != questionsArray.endIndex - 1 {
            cell.nextQButton.isHidden = true
            cell.nextQButton.isUserInteractionEnabled = false
        } else if indexPath.row == questionsArray.endIndex - 1{
            cell.nextQButton.isHidden = false
            cell.nextQButton.isUserInteractionEnabled = true
        }
        optionsLeft = question.ansOptions
        for q in questionsArray {
            
        }
        
        
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset
        
        // calculate where scrollView should snap to:
        let indexOfMajorCell = self.indexOfMajorCell()
        
        // calculate conditions:
        let dataSourceCount = collectionView(questionCollectionView!, numberOfItemsInSection: 0)
        let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < dataSourceCount && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
        
        if didUseSwipeToSkipCell {
            
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = collectionViewFlowLayout.itemSize.width * CGFloat(snapToIndex)
            
            // Damping equal 1 => no oscillations => decay animation:
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                scrollView.layoutIfNeeded()
            }, completion: nil)
            
        } else {
            // This is a much better way to scroll to a cell:
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            collectionViewFlowLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    //MARK: - UIPicker Delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return optionsLeft.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return optionsLeft[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let pointInCollectionView = CGPoint(x: questionCollectionView.center.x + questionCollectionView.contentOffset.x,
                                            y: questionCollectionView.center.y + questionCollectionView.contentOffset.y)
        let indexPath = questionCollectionView?.indexPathForItem(at: pointInCollectionView)

        let cell = questionCollectionView?.cellForItem(at: indexPath!) as! MatchinCollectionViewCell
        cell.userInput.text = optionsLeft[row]
        let question = questionsArray[(indexPath?.row)!]
        question.userAnswer = cell.userInput.text!
        getScoreOfQuestion(question: question)
        self.view.endEditing(true)
        
    }
    
    //MARK - Text Field Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.resignFirstResponder()
        self.view.endEditing(true)
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! HoleQuestionsViewController
        vc.score = score
        vc.user = user
        print("Score so far...\(score)", user.userType)
    }
    
    @IBAction func didPressedNextQuestions(_ sender: Any) {
        
        var s : Float = 0.0
        
        for q in questionsArray {
            s += q.score
            print(q.score, s)
        }
        
        newScore = s/Float(questionsArray.count)
        score = (score + newScore) / 2
        print("Current Score: \(score)")
        
        self.performSegue(withIdentifier: "finalquestionsegue", sender: self)
        
    }
    func questionArray() {
        let opts = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P"]
        questionsArray.append(MatchingQuestion(text: "A piece of sod or turf cut loose by a player's club after making a stroke",
                                               options: opts,
                                               correctA: "D"))
        questionsArray.append(MatchingQuestion(text: "A warning shouted to let a person know that a ball in flight may hit him/her or come very close",
                                               options: opts,
                                               correctA: "I"))
        questionsArray.append(MatchingQuestion(text: "A shot, hit by a right-handed player, which curves slightly right",
                                               options: opts,
                                               correctA: "H"))
        questionsArray.append(MatchingQuestion(text: "The amount of strokes taken with handicap included",
                                               options: opts,
                                               correctA: "L"))
        questionsArray.append(MatchingQuestion(text: "A score one stroke under par for the hole",
                                               options: opts,
                                               correctA: "A"))
        questionsArray.append(MatchingQuestion(text: "Path in which the ball is intended to travel over the putting green to the hole. Do not step on this while on the green",
                                               options: opts,
                                               correctA: "O"))
        questionsArray.append(MatchingQuestion(text: "The amount of strokes taken without handicap",
                                               options: opts,
                                               correctA: "K"))
        questionsArray.append(MatchingQuestion(text: "Ground on which play is prohibited, usually outside the golf course's property. It is usually marked with white stakes or boundary fences",
                                               options: opts,
                                               correctA: "M"))
        questionsArray.append(MatchingQuestion(text: "A shot, hit by a right-handed player, which curves slightly left",
                                               options: opts,
                                               correctA: "F"))
        questionsArray.append(MatchingQuestion(text: "The closely mowed collar around the putting green",
                                               options: opts,
                                               correctA: "J"))
        questionsArray.append(MatchingQuestion(text: "A score one stroke over par for the hole",
                                               options: opts,
                                               correctA: "B"))
        questionsArray.append(MatchingQuestion(text: "A score two strokes under par for the hole",
                                               options: opts,
                                               correctA: "G"))
        questionsArray.append(MatchingQuestion(text: "A hole which goes right or left and does not follow a staight line from the tee",
                                               options: opts,
                                               correctA: "E"))
        questionsArray.append(MatchingQuestion(text: "The standard score for the hole, usually based on its length",
                                               options: opts,
                                               correctA: "P"))
        questionsArray.append(MatchingQuestion(text: "A ball played for the orignal ball which may be lost outside if a water hazard or may be out of bounds",
                                               options: opts,
                                               correctA: "N"))
        questionsArray.append(MatchingQuestion(text: "A depression where the turf or soil has been removed and replaced with sand. It is a hazard. Often improperly called a \"sand trap\"",
                                               options: opts,
                                               correctA: "C"))
        
    }
    
    func getScoreOfQuestion(question:MatchingQuestion) {
        let userAnswer = question.userAnswer
        let correctAnswer = question.correctAns
        
        if userAnswer == correctAnswer{
            question.score = 1
        } else {
            question.score = 0
        }
    }

}
