from lib import plotting, py_asp, helper, induction
import config as cf
import subprocess, json, os

def is_wall_in_background(wall, file):
    '''
    Input: wall tuple and background file (fullpath)

    Output: Boolean to tell whether the wall is already in the background
    '''
    wall = "wall({})".format(str(wall))
    with open(file, "r") as searchfile:
        for line in searchfile:
            if(wall in line):
                searchfile.close()
                return True
    return False

def add_new_walls(previous_state, wall_list, file):
    '''
    Check the surrounding and see if there is any new walls

    Output: Boolean to tell whether a new wall has been added to B
    '''
    x = int(previous_state[0])
    y = int(previous_state[1])
    if(((x+1,y) in wall_list) and (is_wall_in_background((x+1,y), file) == False)):
        wall = "\nwall({}).\n".format((x+1,y))
        helper.append_to_file(wall, file)
    if(((x,y+1) in wall_list) and (is_wall_in_background((x,y+1), file) == False)):
        wall = "\nwall({}).\n".format((x,y+1))
        helper.append_to_file(wall, file)
    if(((x-1,y) in wall_list) and (is_wall_in_background((x-1,y), file) == False)):
        wall = "\nwall({}).\n".format((x-1,y))
        helper.append_to_file(wall, file)
    if(((x,y-1) in wall_list) and (is_wall_in_background((x,y-1), file) == False)):
        wall = "\nwall({}).\n".format((x,y-1))
        helper.append_to_file(wall, file)

def add_start_state(start_state):
    '''
    Add the current state of the agent to ASP program
    '''
    start_state = "%AAA\n" + "state_at((" + str(int(start_state[0])) + ", " + str(int(start_state[1])) + "), 1).\n" + "%BBB\n"
    helper.append_to_file(start_state, cf.CLINGOFILE)

def add_hypothesis(hypothesis_asp):
    '''
    Add learnt hypothese to ASP program
    '''
    helper.append_to_file("%START\n", cf.CLINGOFILE)
    helper.append_to_file(hypothesis_asp, cf.CLINGOFILE)
    helper.append_to_file("%END\n", cf.CLINGOFILE)

def add_goal_state(goal_state):
    '''
    Add goal spec to ASP program
    '''
    goal_state = "state_at((" + str(int(goal_state[0])) + ", " + str(int(goal_state[1])) + "), T),"
    goal = "finished(T):- goal(T2), time(T), T >= T2.\n goal(T):- " + goal_state + " not finished(T-1).\n" + \
    "goalMet:- goal(T).\n:- not goalMet.\n"
    helper.append_to_file(goal, cf.CLINGOFILE)

def make_lp_base(cell_range):
    '''
    Collect all info necessary to run clingo and send them to "cf.CLINGOFILE"
    '''
    actions = "1{action(down, T); action(up, T); action(right, T); action(left, T)}1 :- time(T), not finished(T).\n"
    show = "#show state_at/2.\n #show action/2.\n"
    time = "%CCC\n" +"time(0.." + str(cf.TIME_RANGE) + ").\n" + "%DDD\n"
    minimize = "#minimize{1, X, T: action(X,T)}.\n"

    kb = actions + show  + time + cell_range + minimize + cf.ADJACENT
    helper.append_to_file(kb, cf.CLINGOFILE)

def run_clingo(clingofile):
    '''
    Run clingo to get a sequnce of action plan

    Output: sorted action and state arrays
    '''
    print("clingo running...")
    try:
        planning_actions = subprocess.check_output(["clingo5", "--opt-strat=usc,stratify", "-n", "0", clingofile, "--opt-mode=opt", "--outf=2"], universal_newlines=True)
    except subprocess.CalledProcessError as e:
        planning_actions = e.output
        # When Clingo returns UNSATISFIABLE
        print("Clingo error...", planning_actions)
    json_plan = json.loads(planning_actions)
    # Extract only the optimal answer set (last one)
    is_success = json_plan["Result"]
    if(is_success == "UNSATISFIABLE"):
        return [""]
    size_asp = len(json_plan["Call"][0]["Witnesses"])
    answer_sets = json_plan["Call"][0]["Witnesses"][size_asp-1]["Value"]

    return answer_sets

def sort_planning(answer_sets):
    '''
    Sort the answer sets by time step
    Output: sorted action and state arrays
    '''
    states = []
    actions = []

    # Loop through the string and put state_at and action into different arrays
    for i in answer_sets:
        if "state_at" in i:
            states.append(i)
        if "action" in i:
            actions.append(i)

    states_key = []
    for state in states:
        # key is integer T
        state_key,_,_ = get_T(state)
        states_key.append((state_key, state))
    # Sort them by T
    states_sorted = sorted(states_key, key=lambda tup: tup[0])

    actions_key = []
    for action in actions:
        action_key,_,_ = get_T(action)
        act = extract_action(action)
        actions_key.append((action_key, act))
    # Sort them by T
    actions_sorted = sorted(actions_key, key=lambda tup: tup[0])

    return states_sorted, actions_sorted

def update_T(state):
    '''
    Increment T by 1

    Output: string "state_at"
    '''
    size = len(state)
    time, start_index, end_index = get_T(state)
    time += 1
    return state[0:start_index+1] + str(time) + state[end_index:size]

def get_T(state):
    size = len(state)
    start_index = size
    end_index = size - 1
    for i in range(end_index, 0, -1):
        if state[i] == ",":
            start_index = i
            break
    return int(state[start_index+1: end_index]), start_index, end_index

def update_Y(state, step):
    size = len(state)
    y, start_index, end_index = get_Y(state)
    y += step
    return state[0:start_index+1] + str(y) + state[end_index:size]

def update_X(state, step):
    size = len(state)
    x, start_index, end_index = get_X(state)
    x += step
    return state[0:start_index+1] + str(x) + state[end_index:size]

def get_X(state):
    '''
    Extract X coodinate
    '''
    first_blacket_seen = False
    start_index = end_index = 0
    for index, char in enumerate(state):
        if(char == "(" and first_blacket_seen):
            start_index = index
        if char == "(":
            first_blacket_seen = True
        if char == ",":
            end_index = index
            break
    return int(state[start_index+1: end_index]), start_index, end_index

def get_Y(state):
    '''
    Extract Y coodinate
    '''
    start_index = end_index = 0
    start_index_found = False
    for index, char in enumerate(state):
        if (char == "," and start_index_found == False):
            start_index = index
            start_index_found = True
        if char == ")":
            end_index = index
            break
    return int(state[start_index+1: end_index]), start_index, end_index

def extract_action(action):
    '''
    Input:  e.g action(right,13)
    Output: e.g right
    '''

    start_index = len("action(")

    end_index = start_index
    for a in range(len(action)):
        if action[a] == ",":
            end_index = a
    return action[start_index: end_index]

def is_state_in_states(state, states):
    '''
    check if state is in states answer sets

    states: [(1, 'state_at((4,6),1)'), (2, 'state_at((5,6),2)'), (3, 'state_at((6,6),3)')]
    state:  'state_at((4,6),1)'
    '''

    for s in states:
        if(state == s[1]):
            return True
    return False

def update_time_range(agent_position, t):
    '''
    Update planning starting point based on the location of the agent
    '''
    # Replace everything between "CCC" and "DDD" in clingo file with a new agent position
    t = "%CCC\n" +"time("+ str(t) +".." + str(cf.TIME_RANGE) + ").\n" + "%DDD\n"
    flag = False
    with open(cf.CLINGOFILE) as f:
        for line in f:
            if line == "%CCC\n":
                flag = True
            if flag == False:
                with open("temp.lp", "a") as newfile:
                    newfile.write(line)
            if line == "%DDD\n":
                flag = False
    os.rename("temp.lp", cf.CLINGOFILE)

    helper.append_to_file(t, cf.CLINGOFILE)

def update_agent_position(agent_position, t):
    '''
    Update planning starting point based on the location of the agent
    '''
    # Replace everything between "AAA" and "BBB" in clingo file with a new agent position
    start_state = "%AAA\n" + "state_at((" + str(int(agent_position[0])) + ", " + str(int(agent_position[1])) + "), " + str(t) + ").\n" + "%BBB\n"
    flag = False
    with open(cf.CLINGOFILE) as f:
        for line in f:
            if line == "%AAA\n":
                flag = True
            if flag == False:
                with open("temp.lp", "a") as newfile:
                    newfile.write(line)
            if line == "%BBB\n":
                flag = False
    os.rename("temp.lp", cf.CLINGOFILE)

    helper.append_to_file(start_state, cf.CLINGOFILE)

def update_h(hypothesis):
    '''
    Update planning starting point based on the location of the agent
    '''

    # Replace everything between "START" and "END" in clingo file with a new H
    flag = False
    with open(cf.CLINGOFILE) as f:
        for line in f:
            if line == "%START\n":
                flag = True
            if flag == False:
                with open("temp.lp", "a") as newfile:
                    newfile.write(line)
            if line == "%END\n":
                flag = False
    os.rename("temp.lp", cf.CLINGOFILE)

    helper.append_to_file("%START\n", cf.CLINGOFILE)
    helper.append_to_file(hypothesis, cf.CLINGOFILE)
    helper.append_to_file("%END\n", cf.CLINGOFILE)
