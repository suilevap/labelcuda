#pragma once
#include "State.h"

#include <vector>
#include "TransitionsTable.h"

#define TerminationSymbols " \n~!@#$%^&*()_+=-`{}[];':"",./<>?"

class WordFinder
{
private:
	std::vector<State*> _states;

public:
	

	void AddWord(std::string word, int id);

	void AddWords(std::vector<std::string> words);

	TransitionsTable* Generate();

	WordFinder(void);
	~WordFinder(void);
};
