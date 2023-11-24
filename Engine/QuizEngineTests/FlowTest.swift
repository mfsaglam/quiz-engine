//
//  FlowTest.swift
//  QuizEngineTests
//
//  Created by Fatih Sağlam on 26.08.2023.
//

import Foundation
import XCTest
@testable import QuizEngine

class FlowTest: XCTestCase {
    func test_start_withNoQuestions_doesNotDelegateQuestionHandling() {
        makeSUT(questions: []).start()
        XCTAssertTrue(delegate.questionsAsked.isEmpty)
    }
    
    func test_start_withOneQuestion_delegatesCorrectQuestionHandling() {
        makeSUT(questions: ["Q1"]).start()
        XCTAssertEqual(delegate.questionsAsked, ["Q1"])
    }
    
    func test_start_withOneQuestion_delegatesAnotherCorrectQuestionHandling() {
        makeSUT(questions: ["Q2"]).start()
        XCTAssertEqual(delegate.questionsAsked, ["Q2"])
    }
    
    func test_start_withTwoQuestions_delegatesFirstQuestionHandling() {
        makeSUT(questions: ["Q1", "Q2"]).start()
        XCTAssertEqual(delegate.questionsAsked, ["Q1"])
    }
    
    func test_startTwice_withTwoQuestions_delegatesFirstQuestionHandlingTwice () {
        let sut = makeSUT(questions: ["Q1", "Q2"])
        sut.start()
        sut.start()

        XCTAssertEqual(delegate.questionsAsked, ["Q1", "Q1"])
    }
    
    func test_startAndAnswerFirstAndSecondQuestion_withThreeQuestions_delegatesSecondAndThirdQuestionHandling() {
        let sut = makeSUT(questions: ["Q1", "Q2", "Q3"])
        sut.start()
        delegate.answerCompletions[0]("A1")
        delegate.answerCompletions[1]("A2")

        XCTAssertEqual(delegate.questionsAsked, ["Q1", "Q2", "Q3"])
    }
    
    func test_startAndAnswerFirstQuestion_withOneQuestion_doesNotDelegateQuestionHandling() {
        let sut = makeSUT(questions: ["Q1"])
        sut.start()
        delegate.answerCompletions[0]("A1")

        XCTAssertEqual(delegate.questionsAsked, ["Q1"])
    }
    
    func test_startAndAnswerFirstQuestion_withTwoQuestion_doesNotCompleteQuiz() {
        let sut = makeSUT(questions: ["Q1", "Q2"])
        sut.start()
        delegate.answerCompletions[0]("A1")

        XCTAssertTrue(delegate.completedQuizzes.isEmpty)
    }
    
    func test_start_withNoQuestions_completeWithEmptyQuiz() {
        makeSUT(questions: []).start()
        
        XCTAssertEqual(delegate.completedQuizzes.count, 1)
        XCTAssertTrue(delegate.completedQuizzes[0].isEmpty)
    }
    
    func test_start_withOneQuestion_doesNotCompleteQuiz() {
        makeSUT(questions: ["Q1"]).start()
        
        XCTAssertTrue(delegate.completedQuizzes.isEmpty)
    }
    
    func test_startAndAnswerFirstAndSecondQuestion_withTwoQuestions_completesQuiz() {
        let sut = makeSUT(questions: ["Q1", "Q2"])
        sut.start()
        delegate.answerCompletions[0]("A1")
        delegate.answerCompletions[1]("A2")

        XCTAssertEqual(delegate.completedQuizzes.count, 1)
        assertEqual(delegate.completedQuizzes[0], [("Q1", "A1"), ("Q2", "A2")])
    }
    
    func test_startAndAnswerFirstAndSecondQuestionTwice_withTwoQuestions_completesQuizTwice() {
        let sut = makeSUT(questions: ["Q1", "Q2"])
        sut.start()
        delegate.answerCompletions[0]("A1")
        delegate.answerCompletions[1]("A2")
        
        delegate.answerCompletions[0]("A1-1")
        delegate.answerCompletions[1]("A2-2")

        XCTAssertEqual(delegate.completedQuizzes.count, 2)
        assertEqual(delegate.completedQuizzes[0], [("Q1", "A1"), ("Q2", "A2")])
        assertEqual(delegate.completedQuizzes[1], [("Q1", "A1-1"), ("Q2", "A2-2")])
    }
    
    //MARK: Helpers
    private let delegate = DelegateSpy()
    
    private func makeSUT(
        questions: [String]
    ) -> Flow<DelegateSpy> {
        return Flow(questions: questions, delegate: delegate)
    }
    
    private class DelegateSpy: QuizDelegate {
        var questionsAsked: [String] = []
        var answerCompletions: [((String) -> Void)] = []
        
        var completedQuizzes: [[(String, String)]] = []

        func answer(for question: String, completion: @escaping (String) -> Void) {
            questionsAsked.append(question)
            self.answerCompletions.append(completion)
        }
        
        func didCompleteQuiz(withAnswers answers: [(question: String, answer: String)]) {
            completedQuizzes.append(answers)
        }
    }
}
