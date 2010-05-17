#pragma once
#include "Transition.h"

#define STATE_SIZE (sizeof(Transition) *  256)

class State
{
public:	
	Transition Transitions[256];
	

	void AddManyTransitions(char* symbols, int nextStateId, int output);
	State(void);
	~State(void);
};
