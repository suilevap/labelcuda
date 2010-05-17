
#include "State.h"
#include "string"

State::State(void)
{
	memset(Transitions, 0, STATE_SIZE);
}

State::~State(void)
{
}

void State::AddManyTransitions( char* symbols, int nextStateId, int output )
{
	for (int i = 0; symbols[i] != 0; i++)
	{
		Transitions[symbols[i]].NextState = nextStateId;
		Transitions[symbols[i]].Output = output;
	}
}
