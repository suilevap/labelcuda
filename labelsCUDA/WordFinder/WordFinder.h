#pragma once
#include "State.h"
#include <vector>
#include "TransactionsTable.h"

char* TerminationSymbols = " \n~!@#$%^&*()_+=-`{}[];':"",./<>?";

class WordFinder
{
private:
	std::vector<State*> _states;
public:
	

	void AddWord(char* word, int id);

	TrunsactionsTable* Generate();

	WordFinder(void);
	~WordFinder(void);
};
