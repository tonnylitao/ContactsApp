import {StyleSheet} from 'react-native';

const color = {
  gray: '#696969',
};

export const theme = {
  color: {
    lightText: color.gray,
    cellSeperator: '#ccc',
  },
  padding: 20,
  fontSize: {
    l: 18,
    m: 16,
    s: 14,
  },
  width: {
    avatar: 44,
    avatarLarge: 100,
  },
};

export const style = StyleSheet.create({
  cell: {
    marginLeft: theme.padding,
    marginTop: theme.padding,
    paddingRight: theme.padding,
    paddingBottom: theme.padding,

    borderStyle: 'solid',
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: theme.color.cellSeperator,
  },
  center: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
