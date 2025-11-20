import '../features/knowledge_graph/domain/concept_node.dart';
import '../features/knowledge_graph/domain/knowledge_graph.dart';
import '../features/knowledge_graph/domain/problem_choice.dart';
import '../features/knowledge_graph/domain/problem_node.dart';

KnowledgeGraph buildSampleKnowledgeGraph() {
  final concepts = [
    const ConceptNode(
      id: 'MATH_HIGH1_QUADRATIC_FACTORING',
      title: '이차방정식 인수분해',
      childIds: ['MATH_HIGH1_COMMON_FACTOR', 'MATH_HIGH1_SIGN_RULE'],
    ),
    const ConceptNode(
      id: 'MATH_HIGH1_COMMON_FACTOR',
      title: '공통 인수 찾기',
      parentId: 'MATH_HIGH1_QUADRATIC_FACTORING',
      childIds: ['MATH_HIGH1_MULTIPLICATION_FACTS'],
    ),
    const ConceptNode(
      id: 'MATH_HIGH1_SIGN_RULE',
      title: '부호 연산 규칙',
      parentId: 'MATH_HIGH1_QUADRATIC_FACTORING',
      childIds: [],
    ),
    const ConceptNode(
      id: 'MATH_HIGH1_MULTIPLICATION_FACTS',
      title: '곱셈 기본',
      parentId: 'MATH_HIGH1_COMMON_FACTOR',
    ),
  ];

  final problems = [
    const ProblemNode(
      id: 'PROB-QUAD-01',
      conceptId: 'MATH_HIGH1_QUADRATIC_FACTORING',
      prompt: 'x² + 5x + 6 = 0 을 인수분해 해볼까?',
      childConceptIds: [
        'MATH_HIGH1_COMMON_FACTOR',
        'MATH_HIGH1_SIGN_RULE',
      ],
      difficulty: 3,
      subject: '수학',
      grade: '고1',
      topic: '인수분해',
      correctAnswer: '(x+2)(x+3)=0',
      choices: [
        ProblemChoice(value: '(x+2)(x+3)=0'),
        ProblemChoice(value: '(x+1)(x+6)=0'),
      ],
    ),
    const ProblemNode(
      id: 'PROB-CF-01',
      conceptId: 'MATH_HIGH1_COMMON_FACTOR',
      prompt: '3x + 6 에서 공통인수를 찾아보자.',
      childConceptIds: ['MATH_HIGH1_MULTIPLICATION_FACTS'],
      difficulty: 2,
      subject: '수학',
      grade: '중3',
      topic: '공통인수',
      correctAnswer: '3(x+2)',
      choices: [
        ProblemChoice(value: '3(x+2)'),
        ProblemChoice(value: 'x(3+6)'),
      ],
    ),
    const ProblemNode(
      id: 'PROB-SIGN-01',
      conceptId: 'MATH_HIGH1_SIGN_RULE',
      prompt: '-2 × -3 는 얼마일까?',
      difficulty: 1,
      subject: '수학',
      grade: '중1',
      topic: '정수의 곱셈',
      correctAnswer: '6',
      choices: [
        ProblemChoice(value: '6'),
        ProblemChoice(value: '-6'),
      ],
    ),
    const ProblemNode(
      id: 'PROB-MUL-01',
      conceptId: 'MATH_HIGH1_MULTIPLICATION_FACTS',
      prompt: '2 × 3 = ?',
      difficulty: 1,
      subject: '수학',
      grade: '초6',
      topic: '기초곱셈',
      correctAnswer: '6',
      choices: [
        ProblemChoice(value: '6'),
        ProblemChoice(value: '5'),
      ],
    ),
  ];

  return KnowledgeGraph(concepts: concepts, problems: problems);
}
