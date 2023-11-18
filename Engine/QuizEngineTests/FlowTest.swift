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
        XCTAssertTrue(delegate.handledQuestions.isEmpty)
    }
    
    func test_start_withOneQuestion_delegatesCorrectQuestionHandling() {
        makeSUT(questions: ["Q1"]).start()
        XCTAssertEqual(delegate.handledQuestions, ["Q1"])
    }
    
    func test_start_withOneQuestion_delegatesAnotherCorrectQuestionHandling() {
        makeSUT(questions: ["Q2"]).start()
        XCTAssertEqual(delegate.handledQuestions, ["Q2"])
    }
    
    func test_start_withTwoQuestions_delegatesFirstQuestionHandling() {
        makeSUT(questions: ["Q1", "Q2"]).start()
        XCTAssertEqual(delegate.handledQuestions, ["Q1"])
    }
    
    func test_startTwice_withTwoQuestions_delegatesFirstQuestionHandlingTwice () {
        let sut = makeSUT(questions: ["Q1", "Q2"])
        sut.start()
        sut.start()

        XCTAssertEqual(delegate.handledQuestions, ["Q1", "Q1"])
    }
    
    func test_startAndAnswerFirstAndSecondQuestion_withThreeQuestions_delegatesSecondAndThirdQuestionHandling() {
        let sut = makeSUT(questions: ["Q1", "Q2", "Q3"])
        sut.start()
        delegate.answerCallback("A1")
        delegate.answerCallback("A2")

        XCTAssertEqual(delegate.handledQuestions, ["Q1", "Q2", "Q3"])
    }
    
    func test_startAndAnswerFirstQuestion_withOneQuestion_doesNotDelegateQuestionHandling() {
        let sut = makeSUT(questions: ["Q1"])
        sut.start()
        delegate.answerCallback("A1")

        XCTAssertEqual(delegate.handledQuestions, ["Q1"])
    }
    
    func test_start_withNoQuestions_delegatesResultHandling() {
        makeSUT(questions: []).start()
        XCTAssertEqual(delegate.handledResult?.answers, [:])
    }
    
    func test_start_withOneQuestion_doesNotDelegateResultHandling() {
        let sut = makeSUT(questions: ["Q1"])
        sut.start()

        XCTAssertEqual(delegate.handledResult?.answers, nil)
    }
    
    func test_startAndAnswerFirstQuestion_withTwoQuestions_doesNotDelegateResultHandling() {
        let sut = makeSUT(questions: ["Q1", "Q2"])
        sut.start()
        delegate.answerCallback("A1")

        XCTAssertEqual(delegate.handledResult?.answers, nil)
    }
    
    func test_startAndAnswerFirstAndSecondQuestion_withTwoQuestions_delegatesResultHandling() {
        let sut = makeSUT(questions: ["Q1", "Q2"])
        sut.start()
        delegate.answerCallback("A1")
        delegate.answerCallback("A2")

        XCTAssertEqual(delegate.handledResult?.answers, ["Q1": "A1", "Q2": "A2"])
    }
    
    func test_startAndAnswerFirstAndSecondQuestion_withTwoQuestions_scores() {
        let sut = makeSUT(questions: ["Q1", "Q2"], scoring: { _ in 10 })
        sut.start()
        delegate.answerCallback("A1")
        delegate.answerCallback("A2")

        XCTAssertEqual(delegate.handledResult?.score, 10)
    }
    
    func test_startAndAnswerFirstAndSecondQuestion_withTwoQuestions_scoresWithRightAnswer() {
        var receivedAnswers = [String: String]()
        let sut = makeSUT(questions: ["Q1", "Q2"]) { answers in
            receivedAnswers = answers
            return 20
        }
        sut.start()
        delegate.answerCallback("A1")
        delegate.answerCallback("A2")

        XCTAssertEqual(receivedAnswers, ["Q1": "A1", "Q2": "A2"])
    }
    
    //MARK: Helpers
    private let delegate = DelegateSpy()
    
    private func makeSUT(
        questions: [String],
        scoring: @escaping ([String: String]) -> Int = { _ in 0 }
    ) -> Flow<DelegateSpy> {
        return Flow(questions: questions, delegate: delegate, scoring: scoring)
    }
    
    private class DelegateSpy: QuizDelegate {
        var handledQuestions: [String] = []
        var handledResult: Result<String, String>? = nil
        var answerCallback: ((String) -> Void) = { _ in }
        
        func answer(for question: String, completion: @escaping (String) -> Void) {
            handledQuestions.append(question)
            self.answerCallback = completion
        }
        
        func handle(result: Result<String, String>) {
            handledResult = result
        }
    }
}
