//
//  QuizTest.swift
//  QuizEngineTests
//
//  Created by Fatih Sağlam on 14.11.2023.
//

import Foundation
import XCTest
import QuizEngine

class QuizTest: XCTestCase {
    private let delegate = DelegateSpy()
    private var quiz: Quiz!
    
    override func setUp() {
        quiz = Quiz.start(questions: ["Q1", "Q2"], delegate: delegate, correctAnswers: ["Q1": "A1","Q2": "A2"])
    }
    
    func test_startQuiz_answerZeroOutOfTwoCorrect_scoresZero() {
        delegate.answerCompletion("wrong")
        delegate.answerCompletion("wrong")
        
        XCTAssertEqual(delegate.handledResult!.score, 0)
    }
    
    func test_startQuiz_answerOneOutOfTwoCorrect_scoresOne() {
        delegate.answerCompletion("A1")
        delegate.answerCompletion("wrong")
        
        XCTAssertEqual(delegate.handledResult!.score, 1)
    }
    
    func test_startQuiz_answerTwoOutOfTwoCorrect_scoresTwo() {
        delegate.answerCompletion("A1")
        delegate.answerCompletion("A2")
        
        XCTAssertEqual(delegate.handledResult!.score, 2)
    }
    
    private class DelegateSpy: QuizDelegate {
        var handledResult: Result<String, String>? = nil
        var answerCompletion: ((String) -> Void) = { _ in }
        
        func answer(for: String, completion: @escaping (String) -> Void) {
            self.answerCompletion = completion
        }
        
        func handle(result: Result<String, String>) {
            handledResult = result
        }
    }
}
