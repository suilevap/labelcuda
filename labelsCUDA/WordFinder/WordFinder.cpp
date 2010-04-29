// WordFinder.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "WordFinder.h"


WordFinder::WordFinder(void)
{
	State* state = new State();
	_states.push_back(state);
}

WordFinder::~WordFinder(void)
{
}

void WordFinder::AddWord( char* word, int id )
{
	State* state;
	State* currentState = _states[0];
	
	for (int i = 0; word[i] != 0; i++)
	{
		state = currentState->Transitions[word[i]].NextState;
		
		if (state == NULL)
		{
			state = new State();
			currentState->Transitions[word[i]].NextState = state;
			_states.push_back(state);
		}
		currentState = state;
	}
	currentState->AddManyTransitions(TerminationSymbols, _states[0],id);
}

TrunsactionsTable* WordFinder::Generate()
{
	int size = _states.size();
	TrunsactionsTable* result = new TrunsactionsTable();
	result->Table = new Transition[result->ElementSize * size];
	for (int i = 0; i < size; ++i)
	{
		memcpy( &result->Table[result->ElementSize * i], _states[i]->Transitions, 256);
	}
	return result;
}
