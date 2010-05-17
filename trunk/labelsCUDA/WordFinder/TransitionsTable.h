#pragma once

#define GetState(table, id) (table + id * STATE_SIZE)

#define GetTransaction(table, id, s) ( GetState(table, id)[s])

class TransitionsTable
{
public:
	Transition*  Table;
	int Size;

	TransitionsTable(size_t count)
	{
		Size = count * STATE_SIZE;
		Table = new Transition[Size];
		memset(Table, 0, Size * sizeof(Transition));
	}

	//inline Transition GetTransaction(int id, char symbol)
	//{
	//	//return Table[id * ElementSize + symbol];
	//	return GetState(id)[symbol];
	//}
	//inline Transition* GetState(int id)
	//{
	//	return Table + id * State::StateSize;
	//}

	~TransitionsTable()
	{
		if (Table != NULL)
		{
			delete Table;
		}
	}
};