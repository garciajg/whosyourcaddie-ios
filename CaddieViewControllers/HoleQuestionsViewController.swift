//
//  HoleQuestionsViewController.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 9/12/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit

class HoleQuestionsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,
                                    UIPickerViewDelegate, UIPickerViewDataSource{
    
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
    var tempScore : Float = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        print(user.userType)
        collectionViewFlowLayout.minimumLineSpacing = 0

        pickerView.delegate = self
        pickerView.dataSource = self

        // Do any additional setup after loading the view.
        
        questionArray()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "matchingimagecell", for: indexPath) as! HoleQuestionsCollectionViewCell
        let question = questionsArray[indexPath.row]
        cell.setUp(question: question)
        cell.userInput.inputView = pickerView
        cell.questionTextLabel.text = "\(indexPath.row + 27). \(question.questionText)"
        if indexPath.row != questionsArray.endIndex - 1 {
            cell.finishButton.isHidden = true
            cell.finishButton.isUserInteractionEnabled = false
        } else if indexPath.row == questionsArray.endIndex - 1{
            cell.finishButton.isHidden = false
            cell.finishButton.isUserInteractionEnabled = true
        }
        optionsLeft = question.ansOptions
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.resignFirstResponder()
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
        
        let cell = questionCollectionView?.cellForItem(at: indexPath!) as! HoleQuestionsCollectionViewCell
        cell.userInput.text = optionsLeft[row]
        let question = questionsArray[(indexPath?.row)!]
        question.userAnswer = cell.userInput.text!
        getScoreOfQuestion(question: question)
        
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as! SignUpViewController
        vc.signUpURL = URL(string: "http://0.0.0.0:8000/api/v1/caddie/register")
        vc.score = score

    }

    @IBAction func didPressedFinish(_ sender: Any) {
        
        var s : Float = 0.0
        
        for q in questionsArray {
            s += q.score
            print(q.score, s)
        }
        
        tempScore = s/Float(questionsArray.count)
        score = ((score + tempScore) / 2) * 100
        print("Final Score: \(score)", user.userType)
        if score > 70.0 {
            let message = "You have succesfully passed the exam with a final score of \(String(format: "%.2f", score))%"
            let alert = UIAlertController(title: "Congratulations",
                                          message: message,
                                          preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                self.performSegue(withIdentifier: "tosignupsegue", sender: self)
            }
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            let message = "You got a \(String(format: "%.2f", score))% on the exam. Please pay more attention to the video and try again."
            let alert = UIAlertController(title: "Sorry!",
                                          message: message,
                                          preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                self.performSegue(withIdentifier: "tosignupsegue", sender: self)
            }
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            self.performSegue(withIdentifier: "tosignupsegue", sender: self)
        }
    }
    
    
    func questionArray() {
        let opts = ["A","B","C","D","E","F","G","H","I"]
        questionsArray.append(MatchingQuestion(text: "What's the corresponding term for number 1 on the picture?",
                                               options: opts,
                                               correctA: "C"))
        questionsArray.append(MatchingQuestion(text: "What's the corresponding term for number 2 on the picture?",
                                               options: opts,
                                               correctA: "H"))
        questionsArray.append(MatchingQuestion(text: "What's the corresponding term for number 3 on the picture?",
                                               options: opts,
                                               correctA: "E"))
        questionsArray.append(MatchingQuestion(text: "What's the corresponding term for number 4 on the picture?",
                                               options: opts,
                                               correctA: "A"))
        questionsArray.append(MatchingQuestion(text: "What's the corresponding term for number 5 on the picture?",
                                               options: opts,
                                               correctA: "I"))
        questionsArray.append(MatchingQuestion(text: "What's the corresponding term for number 6 on the picture?",
                                               options: opts,
                                               correctA: "F"))
        questionsArray.append(MatchingQuestion(text: "What's the corresponding term for number 7 on the picture?",
                                               options: opts,
                                               correctA: "G"))
        questionsArray.append(MatchingQuestion(text: "What's the corresponding term for number 8 on the picture?",
                                               options: opts,
                                               correctA: "B"))
        questionsArray.append(MatchingQuestion(text: "What's the corresponding term for number 9 on the picture?",
                                               options: opts,
                                               correctA: "D"))
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
