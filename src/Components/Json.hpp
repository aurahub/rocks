#ifndef LIME_JSON_HPP
#define LIME_JSON_HPP

#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>
#include "../Components/Log.hpp"

namespace Lime {
class ConfigUtil {
 public:
  static bool ParseJson(const std::string json, rapidjson::Document& document) {
    document.SetObject();

    if (document.Parse<0>(json.c_str()).HasParseError()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s], config json parse fail.\n") %
                             __FUNCTION__;
      return false;
    }
    return true;
  }

 public:
  static bool FindString(const rapidjson::Value& object,
                         const std::string& member_name) {
    if (!object.IsObject()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object is not object type!") %
                             __FUNCTION__;
      return false;
    }
    if (!object.HasMember(member_name.c_str())) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object has no member %s!") %
                             __FUNCTION__ % member_name;
      return false;
    }
    if (!object[member_name.c_str()].IsString()) {
      LOG(SYS, ERROR)
          << boost::format("[Config][%s] member %s in object is not string !") %
                 __FUNCTION__ % member_name;
      return false;
    }

    return true;
  }

  static bool FindNumber(const rapidjson::Value& object,
                         const std::string& member_name) {
    if (!object.IsObject()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object is not object type!") %
                             __FUNCTION__;
      return false;
    }
    if (!object.HasMember(member_name.c_str())) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object has no member %s!") %
                             __FUNCTION__ % member_name;
      return false;
    }
    if (!object[member_name.c_str()].IsNumber()) {
      LOG(SYS, ERROR)
          << boost::format("[Config][%s] member %s in object is not number !") %
                 __FUNCTION__ % member_name;
      return false;
    }

    return true;
  }

  static bool FindObject(const rapidjson::Value& object,
                         const std::string& member_name) {
    if (!object.IsObject()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object is not object type!") %
                             __FUNCTION__;
      return false;
    }
    if (!object.HasMember(member_name.c_str())) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object has no member %s!") %
                             __FUNCTION__ % member_name;
      return false;
    }
    if (!object[member_name.c_str()].IsObject()) {
      LOG(SYS, ERROR)
          << boost::format("[Config][%s] member %s in object is not object !") %
                 __FUNCTION__ % member_name;
      return false;
    }

    return true;
  }

  static bool FindArray(const rapidjson::Value& object,
                        const std::string& member_name) {
    if (!object.IsObject()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object is not object type!") %
                             __FUNCTION__;
      return false;
    }
    if (!object.HasMember(member_name.c_str())) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object has no member %s!") %
                             __FUNCTION__ % member_name;
      return false;
    }
    if (!object[member_name.c_str()].IsArray()) {
      LOG(SYS, ERROR)
          << boost::format("[Config][%s] member %s in object is not object !") %
                 __FUNCTION__ % member_name;
      return false;
    }

    return true;
  }

 public:
  static bool MoveObject(rapidjson::Value& array, const size_t& index,
                         rapidjson::Value& value) {
    if (!array.IsArray()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] array is not array type!") %
                             __FUNCTION__;
      return false;
    }
    if (index >= array.Size()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index over array size %d!") %
                             __FUNCTION__ % index;
      return false;
    }
    if (!array[index].IsObject()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index %d in array is not object !") %
                             __FUNCTION__ % index;
      return false;
    }

    value.SetObject();
    value = array[index].Move();

    return true;
  }

  static bool MoveArray(rapidjson::Value& array, const size_t& index,
                        rapidjson::Value& value) {
    if (!array.IsArray()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] array is not array type!") %
                             __FUNCTION__;
      return false;
    }
    if (index >= array.Size()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index over array size %d!") %
                             __FUNCTION__ % index;
      return false;
    }
    if (!array[index].IsArray()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index %d in array is not array !") %
                             __FUNCTION__ % index;
      return false;
    }

    value.SetArray();
    value = array[index].Move();

    return true;
  }

  static bool MoveObject(rapidjson::Value& object,
                         const std::string& member_name,
                         rapidjson::Value& value) {
    if (!object.IsObject()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object is not object type!") %
                             __FUNCTION__;
      return false;
    }
    if (!object.HasMember(member_name.c_str())) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object has no member %s!") %
                             __FUNCTION__ % member_name;
      return false;
    }
    if (!object[member_name.c_str()].IsObject()) {
      LOG(SYS, ERROR)
          << boost::format("[Config][%s] member %s in object is not object !") %
                 __FUNCTION__ % member_name;
      return false;
    }

    value.SetObject();
    value = object[member_name.c_str()].Move();

    return true;
  }

  static bool MoveArray(rapidjson::Value& object,
                        const std::string& member_name,
                        rapidjson::Value& value) {
    if (!object.IsObject()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object is not object type!") %
                             __FUNCTION__;
      return false;
    }
    if (!object.HasMember(member_name.c_str())) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object has no member %s!") %
                             __FUNCTION__ % member_name;
      return false;
    }
    if (!object[member_name.c_str()].IsArray()) {
      LOG(SYS, ERROR)
          << boost::format("[Config][%s] member %s in object is not array !") %
                 __FUNCTION__ % member_name;
      return false;
    }

    value.SetArray();
    value = object[member_name.c_str()].Move();

    return true;
  }

 public:
  static bool ReadIndex(const rapidjson::Value& array, const size_t& index,
                        std::string& value) {
    if (!array.IsArray()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] array is not array type!") %
                             __FUNCTION__;
      return false;
    }
    if (index >= array.Size()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index over array size %d!") %
                             __FUNCTION__ % index;
      return false;
    }
    if (!array[index].IsString()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index %d in array is not string !") %
                             __FUNCTION__ % index;
      return false;
    }

    value = array[index].GetString();

    return true;
  }

  static bool ReadIndex(const rapidjson::Value& array, const size_t& index,
                        int16_t& value) {
    if (!array.IsArray()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] array is not array type!") %
                             __FUNCTION__;
      return false;
    }
    if (index >= array.Size()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index over array size %d!") %
                             __FUNCTION__ % index;
      return false;
    }
    if (!array[index].IsNumber()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index %d in array is not number !") %
                             __FUNCTION__ % index;
      return false;
    }

    value = static_cast<uint16_t>(array[index].GetDouble());

    return true;
  }

  static bool ReadIndex(const rapidjson::Value& array, const size_t& index,
                        uint16_t& value) {
    if (!array.IsArray()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] array is not array type!") %
                             __FUNCTION__;
      return false;
    }
    if (index >= array.Size()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index over array size %d!") %
                             __FUNCTION__ % index;
      return false;
    }
    if (!array[index].IsNumber()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index %d in array is not number !") %
                             __FUNCTION__ % index;
      return false;
    }

    value = static_cast<int16_t>(array[index].GetDouble());

    return true;
  }

  static bool ReadIndex(const rapidjson::Value& array, const size_t& index,
                        int32_t& value) {
    if (!array.IsArray()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] array is not array type!") %
                             __FUNCTION__;
      return false;
    }
    if (index >= array.Size()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index over array size %d!") %
                             __FUNCTION__ % index;
      return false;
    }
    if (!array[index].IsNumber()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index %d in array is not number !") %
                             __FUNCTION__ % index;
      return false;
    }

    value = static_cast<int32_t>(array[index].GetDouble());

    return true;
  }

  static bool ReadIndex(const rapidjson::Value& array, const size_t& index,
                        uint32_t& value) {
    if (!array.IsArray()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] array is not array type!") %
                             __FUNCTION__;
      return false;
    }
    if (index >= array.Size()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index over array size %d!") %
                             __FUNCTION__ % index;
      return false;
    }
    if (!array[index].IsNumber()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index %d in array is not number !") %
                             __FUNCTION__ % index;
      return false;
    }

    value = static_cast<uint32_t>(array[index].GetDouble());

    return true;
  }

  static bool ReadIndex(const rapidjson::Value& array, const size_t& index,
                        int64_t& value) {
    if (!array.IsArray()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] array is not array type!") %
                             __FUNCTION__;
      return false;
    }
    if (index >= array.Size()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index over array size %d!") %
                             __FUNCTION__ % index;
      return false;
    }
    if (!array[index].IsNumber()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index %d in array is not number !") %
                             __FUNCTION__ % index;
      return false;
    }

    value = static_cast<int64_t>(array[index].GetDouble());

    return true;
  }

  static bool ReadIndex(const rapidjson::Value& array, const size_t& index,
                        uint64_t& value) {
    if (!array.IsArray()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] array is not array type!") %
                             __FUNCTION__;
      return false;
    }
    if (index >= array.Size()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index over array size %d!") %
                             __FUNCTION__ % index;
      return false;
    }
    if (!array[index].IsNumber()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index %d in array is not number !") %
                             __FUNCTION__ % index;
      return false;
    }

    value = static_cast<uint64_t>(array[index].GetDouble());

    return true;
  }

  static bool ReadIndex(const rapidjson::Value& array, const size_t& index,
                        float& value) {
    if (!array.IsArray()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] array is not array type!") %
                             __FUNCTION__;
      return false;
    }
    if (index >= array.Size()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index over array size %d!") %
                             __FUNCTION__ % index;
      return false;
    }
    if (!array[index].IsNumber()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index %d in array is not number !") %
                             __FUNCTION__ % index;
      return false;
    }

    value = static_cast<float>(array[index].GetDouble());

    return true;
  }

  static bool ReadIndex(const rapidjson::Value& array, const size_t& index,
                        double& value) {
    if (!array.IsArray()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] array is not array type!") %
                             __FUNCTION__;
      return false;
    }
    if (index >= array.Size()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index over array size %d!") %
                             __FUNCTION__ % index;
      return false;
    }
    if (!array[index].IsNumber()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] index %d in array is not number !") %
                             __FUNCTION__ % index;
      return false;
    }

    value = static_cast<double>(array[index].GetDouble());

    return true;
  }

 public:
  static bool ReadMember(const rapidjson::Value& object,
                         const std::string& member_name, std::string& value) {
    if (!object.IsObject()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object is not object type!") %
                             __FUNCTION__;
      return false;
    }
    if (!object.HasMember(member_name.c_str())) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object has no member %s!") %
                             __FUNCTION__ % member_name;
      return false;
    }
    if (!object[member_name.c_str()].IsString()) {
      LOG(SYS, ERROR)
          << boost::format("[Config][%s] member %s in object is not string !") %
                 __FUNCTION__ % member_name;
      return false;
    }

    value = object[member_name.c_str()].GetString();

    return true;
  }

  static bool ReadMember(const rapidjson::Value& object,
                         const std::string& member_name, int16_t& value) {
    if (!object.IsObject()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object is not object type!") %
                             __FUNCTION__;
      return false;
    }
    if (!object.HasMember(member_name.c_str())) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object has no member %s!") %
                             __FUNCTION__ % member_name;
      return false;
    }
    if (!object[member_name.c_str()].IsNumber()) {
      LOG(SYS, ERROR)
          << boost::format("[Config][%s] member %s in object is not number !") %
                 __FUNCTION__ % member_name;
      return false;
    }

    value = static_cast<int16_t>(object[member_name.c_str()].GetDouble());

    return true;
  }

  static bool ReadMember(const rapidjson::Value& object,
                         const std::string& member_name, uint16_t& value) {
    if (!object.IsObject()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object is not object type!") %
                             __FUNCTION__;
      return false;
    }
    if (!object.HasMember(member_name.c_str())) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object has no member %s!") %
                             __FUNCTION__ % member_name;
      return false;
    }
    if (!object[member_name.c_str()].IsNumber()) {
      LOG(SYS, ERROR)
          << boost::format("[Config][%s] member %s in object is not number !") %
                 __FUNCTION__ % member_name;
      return false;
    }

    value = static_cast<uint16_t>(object[member_name.c_str()].GetDouble());

    return true;
  }

  static bool ReadMember(const rapidjson::Value& object,
                         const std::string& member_name, int32_t& value) {
    if (!object.IsObject()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object is not object type!") %
                             __FUNCTION__;
      return false;
    }
    if (!object.HasMember(member_name.c_str())) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object has no member %s!") %
                             __FUNCTION__ % member_name;
      return false;
    }
    if (!object[member_name.c_str()].IsNumber()) {
      LOG(SYS, ERROR)
          << boost::format("[Config][%s] member %s in object is not number !") %
                 __FUNCTION__ % member_name;
      return false;
    }

    value = static_cast<int32_t>(object[member_name.c_str()].GetDouble());

    return true;
  }

  static bool ReadMember(const rapidjson::Value& object,
                         const std::string& member_name, uint32_t& value) {
    if (!object.IsObject()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object is not object type!") %
                             __FUNCTION__;
      return false;
    }
    if (!object.HasMember(member_name.c_str())) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object has no member %s!") %
                             __FUNCTION__ % member_name;
      return false;
    }
    if (!object[member_name.c_str()].IsNumber()) {
      LOG(SYS, ERROR)
          << boost::format("[Config][%s] member %s in object is not number !") %
                 __FUNCTION__ % member_name;
      return false;
    }

    value = static_cast<uint32_t>(object[member_name.c_str()].GetDouble());

    return true;
  }

  static bool ReadMember(const rapidjson::Value& object,
                         const std::string& member_name, int64_t& value) {
    if (!object.IsObject()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object is not object type!") %
                             __FUNCTION__;
      return false;
    }
    if (!object.HasMember(member_name.c_str())) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object has no member %s!") %
                             __FUNCTION__ % member_name;
      return false;
    }
    if (!object[member_name.c_str()].IsNumber()) {
      LOG(SYS, ERROR)
          << boost::format("[Config][%s] member %s in object is not number !") %
                 __FUNCTION__ % member_name;
      return false;
    }

    value = static_cast<int64_t>(object[member_name.c_str()].GetDouble());

    return true;
  }

  static bool ReadMember(const rapidjson::Value& object,
                         const std::string& member_name, uint64_t& value) {
    if (!object.IsObject()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object is not object type!") %
                             __FUNCTION__;
      return false;
    }
    if (!object.HasMember(member_name.c_str())) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object has no member %s!") %
                             __FUNCTION__ % member_name;
      return false;
    }
    if (!object[member_name.c_str()].IsNumber()) {
      LOG(SYS, ERROR)
          << boost::format("[Config][%s] member %s in object is not number !") %
                 __FUNCTION__ % member_name;
      return false;
    }

    value = static_cast<uint64_t>(object[member_name.c_str()].GetDouble());

    return true;
  }

  static bool ReadMember(const rapidjson::Value& object,
                         const std::string& member_name, float& value) {
    if (!object.IsObject()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object is not object type!") %
                             __FUNCTION__;
      return false;
    }
    if (!object.HasMember(member_name.c_str())) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object has no member %s!") %
                             __FUNCTION__ % member_name;
      return false;
    }
    if (!object[member_name.c_str()].IsNumber()) {
      LOG(SYS, ERROR)
          << boost::format("[Config][%s] member %s in object is not number !") %
                 __FUNCTION__ % member_name;
      return false;
    }

    value = static_cast<float>(object[member_name.c_str()].GetDouble());

    return true;
  }

  static bool ReadMember(const rapidjson::Value& object,
                         const std::string& member_name, double& value) {
    if (!object.IsObject()) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object is not object type!") %
                             __FUNCTION__;
      return false;
    }
    if (!object.HasMember(member_name.c_str())) {
      LOG(SYS, ERROR) << boost::format(
                             "[Config][%s] object has no member %s!") %
                             __FUNCTION__ % member_name;
      return false;
    }
    if (!object[member_name.c_str()].IsNumber()) {
      LOG(SYS, ERROR)
          << boost::format("[Config][%s] member %s in object is not number !") %
                 __FUNCTION__ % member_name;
      return false;
    }

    value = static_cast<double>(object[member_name.c_str()].GetDouble());

    return true;
  }

 protected:
  std::string json;
  rapidjson::Document document;
};

#define CONFIG_CREATE_DOCUMENT(document, json)  \
  rapidjson::Document document;                 \
  if (!ConfigUtil::ParseJson(json, document)) { \
    return false;                               \
  }

#define CONFIG_FOREACH_OBJECT(array, value)                  \
  for (size_t _index = 0; _index < array.Size(); ++_index) { \
    rapidjson::Value value;                                  \
    if (!ConfigUtil::MoveObject(array, _index, value)) {     \
      return false;                                          \
    }

#define CONFIG_FOREACH_ARRAY(array, value)                   \
  for (size_t _index = 0; _index < array.Size(); ++_index) { \
    rapidjson::Value value;                                  \
    if (!ConfigUtil::MoveArray(array, _index, value)) {      \
      return false;                                          \
    }

#define CONFIG_FOREACH_INDEX(array, _index) \
  for (size_t _index = 0; index < array.Size(); ++_index) {
#define CONFIG_FOREACH_END }

#define CONFIG_READ_MEMBER(object, member_name, value)       \
  if (!ConfigUtil::ReadMember(object, member_name, value)) { \
    return false;                                            \
  }

#define CONFIG_READ_INDEX(array, index, value)       \
  if (!ConfigUtil::ReadIndex(array, index, value)) { \
    return false;                                    \
  }

#define CONFIG_MOVE_OBJECT(object, member_name_or_index, value)       \
  rapidjson::Value value;                                             \
  if (!ConfigUtil::MoveObject(object, member_name_or_index, value)) { \
    return false;                                                     \
  }

#define CONFIG_MOVE_ARRAY(object, member_name_or_index, value)       \
  rapidjson::Value value;                                            \
  if (!ConfigUtil::MoveArray(object, member_name_or_index, value)) { \
    return false;                                                    \
  }
#define CONFIG_FIND_STRING(object, member_name)       \
  if (!ConfigUtil::FindString(object, member_name)) { \
    return false;                                     \
  }

#define CONFIG_FIND_NUMBER(object, member_name)       \
  if (!ConfigUtil::FindNumber(object, member_name)) { \
    return false;                                     \
  }

#define CONFIG_FIND_OBJECT(object, member_name)       \
  if (!ConfigUtil::FindObject(object, member_name)) { \
    return false;                                     \
  }

#define CONFIG_FIND_ARRAY(object, member_name)       \
  if (!ConfigUtil::FindArray(object, member_name)) { \
    return false;                                    \
  }
}  // namespace Lime

#endif  // !LIME_JSON_HPP
