#pragma once
#include "Transition.h"



class State
{
public:	
	Transition Transitions[256];
	static const int StateSize = sizeof(Transition) *  256;

	void AddManyTransitions(char* symbols, int nextStateId, int output);
	State(void);
	~State(void);
};
