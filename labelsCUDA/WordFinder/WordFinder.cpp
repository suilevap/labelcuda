// WordFinder.cpp : Defines the entry point for the console application.
//

#include "WordFinder.h"


WordFinder::WordFinder(void)
{
	State* state = new State();
	_states.push_back(state);
}

WordFinder::~WordFinder(void)
{
}

void WordFinder::AddWord( std::string word, int id )
{
	int stateId;
	State* state;
	int currentStateId = 0;
	State* currentState;

	for (int i = 0; word[i] != 0; i++)
	{
		currentState = _states[currentStateId];
		stateId = currentState->Transitions[word[i]].NextState;
		
		if (stateId == 0)
		{
			state = new State();
			_states.push_back(state);
			stateId = _states.size() - 1;
			currentState->Transitions[word[i]].NextState = stateId;
		}
		currentStateId = stateId;
	}
	currentState->AddManyTransitions(TerminationSymbols, 0, id);
}

TrunsactionsTable* WordFinder::Generate()
{
	size_t size = _states.size();
	TrunsactionsTable* result = new TrunsactionsTable(size);
	for (size_t i = 0; i < size; ++i)
	{
		Transition * transaction =  result->GetState(i);
		memcpy( transaction, _states[i]->Transitions, State::StateSize );
	}
	return result;
}

void WordFinder::AddWords( std::vector<std::string> words )
{
	for (int i = 0; i < words.size(); i++)
	{
		AddWord(words[i], i+1);
	}
}
