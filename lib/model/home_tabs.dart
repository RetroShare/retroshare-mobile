import 'package:retroshare/common/person_delegate.dart';

class Page {
  Page({this.label});
  final String label;
  String get id => label[0];
  @override
  String toString() => '$runtimeType("$label")';
}

final Map<Page, List<PersonDelegateData>> allPages =
<Page, List<PersonDelegateData>>{
  Page(label: 'Chats'): <PersonDelegateData>[
    const PersonDelegateData(
      name: 'Sandie Gloop',
    ),
    const PersonDelegateData(
      name: 'May Doris Sparrow',
    ),
    const PersonDelegateData(
      name: 'Best room ever!',
    ),
    const PersonDelegateData(
      name: 'Andrew Walker',
    ),
    const PersonDelegateData(
      name: 'Do you feel that vibe?',
    ),
    const PersonDelegateData(
      name: 'Alison Platt',
    ),
    const PersonDelegateData(
      name: 'Ocean Greenwald',
    ),
    const PersonDelegateData(
      name: 'May Doris Sparrow',
    ),
    const PersonDelegateData(
      name: 'Best room ever!',
    ),
    const PersonDelegateData(
      name: 'Andrew Walker',
    ),
    const PersonDelegateData(
      name: 'Do you feel that vibe?',
    ),
    const PersonDelegateData(
      name: 'Alison Platt',
    ),
    const PersonDelegateData(
      name: 'Ocean Greenwald',
    ),
  ],
  Page(label: 'Friends'): <PersonDelegateData>[
    const PersonDelegateData(
      name: 'Alison Platt',
    ),
    const PersonDelegateData(
      name: 'Harriet Rabbit',
    ),
    const PersonDelegateData(
      name: 'Helen Parker',
    ),
  ],
};