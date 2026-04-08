#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>
#include <nlohmann/json.hpp>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

using json = nlohmann::json;
const std::string FILE_PATH = "todo.json";
const std::string PIPE_PATH = "/tmp/todo_pipe";

void ensure_resources() {
    std::ifstream f(FILE_PATH);
    if (!f.good()) {
        std::ofstream out(FILE_PATH);
        out << R"({"high": [], "low": [], "keep_looking": []})";
    }
    mkfifo(PIPE_PATH.c_str(), 0666);
}

json read_json() {
    std::ifstream f(FILE_PATH);
    json j; f >> j; return j;
}

void write_and_broadcast(const json& j) {
    std::ofstream f(FILE_PATH);
    f << j.dump(4);
    std::cout << j.dump() << std::endl; // For eww's deflisten
}

void handle_command(std::string line) {
    std::stringstream ss(line);
    std::string action, priority, id_str, desc;
    ss >> action >> priority;

    json j = read_json();

    if (action == "add") {
        std::getline(ss, desc);
        if (!desc.empty() && desc[0] == ' ') desc.erase(0, 1);
        int id = j[priority].empty() ? 1 : j[priority].back()["id"].get<int>() + 1;
        j[priority].push_back({{"id", id}, {"text", desc}, {"completed", false}});
    } 
    else if (action == "toggle") {
        ss >> id_str;
        int target_id = std::stoi(id_str);
        for (auto& item : j[priority]) {
            if (item["id"] == target_id) {
                item["completed"] = !item["completed"].get<bool>();
                break;
            }
        }
    }
    else if (action == "remove") {
        ss >> id_str;
        int target_id = std::stoi(id_str);
        auto& arr = j[priority];
        for (auto it = arr.begin(); it != arr.end(); ++it) {
            if ((*it)["id"] == target_id) { arr.erase(it); break; }
        }
    }
    else if (action == "clear") {
        json new_arr = json::array();
        for (auto& item : j[priority]) {
            if (!item["completed"].get<bool>()) new_arr.push_back(item);
        }
        j[priority] = new_arr;
    }

    write_and_broadcast(j);
}

int main() {
    ensure_resources();
    std::cout << read_json().dump() << std::endl; // Init

    while (true) {
        int fd = open(PIPE_PATH.c_str(), O_RDONLY);
        char buf[1024];
        ssize_t n = read(fd, buf, sizeof(buf)-1);
        if (n > 0) {
            buf[n] = '\0';
            std::stringstream stream(buf);
            std::string cmd_line;
            while(std::getline(stream, cmd_line)) { if(!cmd_line.empty()) handle_command(cmd_line); }
        }
        close(fd);
    }
    return 0;
}