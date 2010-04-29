#include "StdAfx.h"
#include "State.h"

State::State(void)
{
}

State::~State(void)
{
}

void State::AddManyTransitions( char* symbols, State* nextState, int output )
{
	for (int i = 0; symbols[i] != 0; i++)
	{
		Transitions[symbols[i]].NextState = nextState;
		Transitions[symbols[i]].Output = output;
	}
}
