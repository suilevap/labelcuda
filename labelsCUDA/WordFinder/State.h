#pragma once
#include "Transition.h"



class State
{
public:
	Transition Transitions[256];

	void AddManyTransitions(char* symbols, State* nextState, int output);
	State(void);
	~State(void);
};
