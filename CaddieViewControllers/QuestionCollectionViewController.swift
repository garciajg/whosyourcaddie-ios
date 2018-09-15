//
//  QuestionCollectionViewController.swift
//  
//
//  Created by Jose Garcia on 8/30/18.
//

import UIKit

private let reuseIdentifier = "Cell"

class QuestionCollectionViewController: UICollectionViewController {
    
    var questionArray : [Question] = []
    var score : Float = 0.0
    var userAns : [String] = []
    var user = User()
    
    private var indexOfCellBeforeDragging = 0
    private var collectionViewFlowLayout: UICollectionViewFlowLayout {
        return collectionViewLayout as! UICollectionViewFlowLayout
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print(user.userType)
        collectionViewFlowLayout.minimumLineSpacing = 0

        getQuestions()

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
        
        collectionViewFlowLayout.itemSize = CGSize(width: collectionViewLayout.collectionView!.frame.size.width - inset * 2, height: collectionViewLayout.collectionView!.frame.size.height)
    }
    
    private func indexOfMajorCell() -> Int {
        let itemWidth = collectionViewFlowLayout.itemSize.width
        let proportionalOffset = collectionViewLayout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let numberOfItems = collectionView?.numberOfItems(inSection: 0)
        let safeIndex = max(0, min(numberOfItems! - 1, index))
        return safeIndex
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! MatchingQuestionsViewController
        vc.score = score
        vc.user = self.user

    }


    // MARK: UICollectionViewDataSource
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questionArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "questioncell", for: indexPath) as! QuestionCollectionViewCell
        let question = questionArray[indexPath.row]
        cell.questionTextLabel?.text = "\(indexPath.row + 1). \(question.questionText)"
        cell.setUp(question: question)
        
        cell.answerOneLabel.isUserInteractionEnabled = true
        cell.answerTwoLabel.isUserInteractionEnabled = true
        cell.answerThreeLabel.isUserInteractionEnabled = true
        cell.answerFourLabel.isUserInteractionEnabled = true
        
        cell.answerOneLabel.tag = 1
        cell.answerTwoLabel.tag = 2
        cell.answerThreeLabel.tag = 3
        cell.answerFourLabel.tag = 4
        
        let labelOneTapG = UITapGestureRecognizer(target:self, action: #selector(didPressLabel))
        let labelTwoTapG = UITapGestureRecognizer(target:self, action: #selector(didPressLabel))
        let labelThreeTapG = UITapGestureRecognizer(target:self, action: #selector(didPressLabel))
        let labelFourTapG = UITapGestureRecognizer(target:self, action: #selector(didPressLabel))
        cell.answerOneLabel.addGestureRecognizer(labelOneTapG)
        cell.answerTwoLabel.addGestureRecognizer(labelTwoTapG)
        cell.answerThreeLabel.addGestureRecognizer(labelThreeTapG)
        cell.answerFourLabel.addGestureRecognizer(labelFourTapG)
        
        if indexPath.row != questionArray.endIndex - 1 {
            cell.nextQButton.isHidden = true
            cell.nextQButton.isUserInteractionEnabled = false
        } else if indexPath.row == questionArray.endIndex - 1{
            cell.nextQButton.isHidden = false
            cell.nextQButton.isUserInteractionEnabled = true
        }
        
        if question.ansOptions.count < 3 {
            cell.answerThreeLabel.isHidden = true
            cell.answerFourLabel.isHidden = true
            cell.answerOneLabel.text = question.ansOptions[0]
            cell.answerTwoLabel.text = question.ansOptions[1]
            
        } else if question.ansOptions.count > 2 {
            cell.answerThreeLabel.isHidden = false
            cell.answerFourLabel.isHidden = false
            cell.answerOneLabel.text = question.ansOptions[0]
            cell.answerTwoLabel.text = question.ansOptions[1]
            cell.answerThreeLabel.text = question.ansOptions[2]
            cell.answerFourLabel.text = question.ansOptions[3]
            
        }
        
        return cell
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset
        
        // calculate where scrollView should snap to:
        let indexOfMajorCell = self.indexOfMajorCell()
        
        // calculate conditions:
        let dataSourceCount = collectionView(collectionView!, numberOfItemsInSection: 0)
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
            collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
        print(indexOfCellBeforeDragging)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    @objc func didPressLabel(_ sender: UITapGestureRecognizer) {
        let pointInCollectionView = sender.location(in: collectionView)
        let indexPath = collectionView?.indexPathForItem(at: pointInCollectionView)
        
        let redColor = UIColor.alizarin
        let initialColor = UIColor(red: 186/255, green: 237/255, blue: 1, alpha: 1)
        
        let label = sender.view as! UILabel
        let answer = String((label.text?.lowercased().first)!)
        var answers = questionArray[(indexPath?.row)!].userAnswers

        if answers.contains(answer) {
            answers = answers.filter { $0 != answer }
            label.backgroundColor = initialColor
        } else {
            answers.append(answer)
            label.backgroundColor = redColor
        }
        
        questionArray[(indexPath?.row)!].userAnswers = answers
        getScoreOfQuestion(question: questionArray[(indexPath?.row)!])
    }
    
    
    @IBAction func didPressNextButton(_ sender: Any) {
        
        var s : Float = 0.0
        
        for q in questionArray {
            s += q.score
            print(q.score, s)
        }
        
        score = s/Float(questionArray.count)
        print(score)
        performSegue(withIdentifier: "matchingquestionssegue", sender: self)
    }
    
    
    
    func getQuestions() {
        questionArray.append(Question(text: "It is correct to pick up your player’s golf ball if you cannot identify the brand and number. ",
                                      options: ["True","False"],
                                      correctAns: ["f"]))
        questionArray.append(Question(text: "When the caddie superintendent assigns you a golfer, you may turn it down if you would like to caddie for someone else.",
                                      options: ["True","False"],
                                      correctAns: ["f"]))
        questionArray.append(Question(text: "It is correct to demand from your player their golf club immediately after everyone has hit their tee shot.",
                                      options: ["True","False"],
                                      correctAns: ["f"]))
        questionArray.append(Question(text: "In a greenside bunker, if your player fails to reach the putting green, stay with him/her and come back later to rake the sand or ask for another caddie’s assistance. ",
                                      options: ["True","False"],
                                      correctAns: ["t"]))
        questionArray.append(Question(text: "The caddie whose player is first to reach the putting green will be expected to handle the flagstick duties. ",
                                      options: ["True","False"],
                                      correctAns: ["t"]))
        questionArray.append(Question(text: "Which of the following practices will help you become a good caddie?",
                                      options: ["a. Make sure to hustle.",
                                                "b. Have a good attitude.",
                                                "c. Offer your player advice even when you are not asked.",
                                                "d. If you do not know how to do something, do not ask your player because he/she may become angry."],
                                      correctAns: ["a","b"]))
        questionArray.append(Question(text: "Before you start your round of golf, you should:",
                                      options: ["a. Count and arrange your player’s golf clubs.",
                                                "b. Adjust the strap so the bag fits properly on your shoulder.",
                                                "c. Remove the umbrella from the bag because it is added weight.",
                                                "d. Take notice of the type of golf clubs and ball that your player is using."],
                                      correctAns: ["a","b","d"]))
        questionArray.append(Question(text: "Which of the following are the caddies’ duties around the putting green?",
                                      options: ["a. Cleaning your player’s and other’s golf balls.",
                                                "b. Tending the flagstick.",
                                                """
                                                c. Being ready to move so as not to be in anyone’s “line of sight.”
                                                """,
                                                "d. Returning the flagstick once all the players have finished putting."],
                                      correctAns: ["a","b","c","d"]))
        questionArray.append(Question(text: "Which of the following are your duties through the fairway?",
                                      options: ["a. Calculate the distance from your player’s golf ball and the putting green.",
                                                "b. Take notice of where the flagstick is located on the putting green.",
                                                "c. Place the bag upright near your player’s golf ball so that club selection is made easier.",
                                                "d. Walk behind your golfer and follow him/her to the location of their ball."],
                                      correctAns: ["a","b","c"]))
        questionArray.append(Question(text: "Which of the following are required to be eligible to qualify for the Chick Evans Caddie Scholarship?",
                                      options: ["a. Candidates must have caddied, successfully and regularly, for a minimum of two years and are also expected to caddie and/or work at their sponsoring club during the summer when they apply for the scholarship.",
                                                "b. Candidates must have completed their junior year of high school with above a B average in college preparatory courses and have taken the ACT.",
                                                "c. Candidates must clearly establish their need for financial assistance.",
                                                "d. Candidates must be outstanding in character, integrity and leadership."],
                                      correctAns: ["a","b","c","d"]))
    }
    
    func getScoreOfQuestion(question:Question) {
        let userAnswers = question.userAnswers
        let correctAnswers = question.correctAnswer
        var tempArray : [String] = []
        var wrongAnswers : [String] = []
        var numerator : Int = 0
        
        let denominator = correctAnswers.count
        
        for answer in userAnswers {
            if correctAnswers.contains(answer) {
                tempArray.append(answer)
                numerator += 1
            } else {
                wrongAnswers.append(answer)
                numerator = 0
            }
        }

        if wrongAnswers.count >= 1 {
            numerator = 0
        }
        
        question.score = Float(numerator)/Float(denominator)
    }

}
